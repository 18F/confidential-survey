require 'rails_helper'

RSpec.describe SurveysController, type: :controller do
  describe 'show' do
    context 'for a survey using disposable tokens' do
      let(:token) { SurveyToken.generate('sample-survey') }
      
      context 'for an active survey' do
        it 'should return a 200' do
          get :show, id: 'sample-survey', token: token
          expect(response).to have_http_status(:ok)
        end
        
        it 'renders the show template' do
          get :show, id: 'sample-survey', token: token
          expect(response).to render_template('show')
        end
        
        it' should instantiate a Markdown processor' do
          get :show, id: 'sample-survey', token: token
          expect(assigns(:md)).to_not be_nil
        end

        it 'should not destroy the token' do
          get :show, id: 'sample-survey', token: token
          expect(SurveyToken.valid?('sample-survey', token)).to be_truthy
        end
      end

      context 'for a nonexistant survey' do
        it 'should return a 404' do
          get :show, id: 'blah', token: token
          expect(response).to have_http_status(:not_found)
        end

        it 'should not destroy the token' do
          get :show, id: 'blah', token: token
          expect(SurveyToken.valid?('sample-survey', token)).to be_truthy
        end
      end

      context 'for an inactive survey' do
        it 'should return a 404' do
          expect_any_instance_of(Survey).to receive(:active?).and_return(false)
          get :show, id: 'sample-survey'
          expect(response).to have_http_status(:not_found)
        end

        it 'should not destroy the token' do
          get :show, id: 'sample-survey', token: token
          expect(SurveyToken.valid?('sample-survey', token)).to be_truthy
        end
      end

      context 'when the user does not present a token' do
        it 'should return a 404' do
          get :show, id: 'sample-survey'
          expect(response).to have_http_status(:not_found)
        end
      end
    end
    
    context 'for a survey using HTTP authentication' do
      # TODO
    end
    
    context 'for a JSON request' do
      it 'should return a JSON file' do
        get :show, id: 'sample-survey', format: 'json'
        expect(response).to have_http_status(:ok)
        expect { JSON.parse(response.body) }.to_not raise_error
      end
    
      it 'should return a 404 if not active' do
        expect_any_instance_of(Survey).to receive(:active?).and_return(false)
        get :show, id: 'sample-survey', format: 'json'
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'submit' do
    let(:survey) { Survey.new('sample-survey') }
    let(:token) { SurveyToken.generate('sample-survey') }
    let(:survey_id) { 'sample-survey' }
    let(:params) do
      {'survey' => {
         'name' => 'Jacob Harris',
         'desserts' => %w(cake cookies),
         'ice-cream' => ['yes'],
         'flavor' => ['chocolate'],
         'toppings' => %w(sprinkles brownies)},
       'token' => token,
       'id' => survey_id
      }
    end

    context 'for a form using token-based authentication' do
      before { Tally.delete_all }
      
      context 'for an active survey' do
        it 'should redirect to the Thank You page' do
          post :submit, params
          expect(response).to redirect_to(thanks_path)
        end
        
        it 'should record the responses' do
          post :submit, params
          expect(Tally.count).to be > 0
        end
        
        it 'should destroy the token' do
          expect(survey.valid_token?(token)).to be_truthy
          post :submit, params
          expect(survey.valid_token?(token)).to be_falsey
        end
        
        it 'should not allow replays with the same token' do
          expect(survey.valid_token?(token)).to be_truthy
          post :submit, params
          t1 = survey.tally_for('ice-cream', 'yes')
          expect(t1).to eq(1)
          
          post :submit, params
          expect(response).to have_http_status(:not_found)
          expect(survey.tally_for('ice-cream', 'yes')).to eq(t1)
        end
      end

      context 'for an inactive survey' do
        before { expect_any_instance_of(Survey).to receive(:active?).and_return(false) }

        it 'should return a 404' do
          post :submit, params
          expect(response).to have_http_status(:not_found)          
        end

        it 'should not record the survey responses' do
          post :submit, params
          expect(Tally.count).to eq(0)
        end
        
        it 'should not destroy the token' do
          post :submit, params
          expect(survey.valid_token?(token)).to be_truthy
        end
      end

      context 'when the survey is not found' do
        let(:survey_id) { 'foo' }

        it 'should return a 404' do
          post :submit, params
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the user does not present a token' do
        let(:token) { nil }
        
        it 'should return a 404' do
          post :submit, params
          expect(response).to have_http_status(:not_found)
        end
        
        it 'should not record the survey responses' do
          post :submit, params
          expect(Tally.count).to eq(0)
        end
      end
    end
  end

  describe 'generate_token' do
    it 'should fail unless the user authenticates as an admin' do
      get :generate_token, id: 'sample-survey'
      expect(response).to have_http_status(:unauthorized)
    end
    
    it 'should generate and a single token and return one url if passed no argument' do
      SurveyToken.delete_all
      auth_login
      get :generate_token, {id: 'sample-survey'}
      expect(response).to have_http_status(:ok)
      token = SurveyToken.first
      expect(token).to_not be_nil
      expect(response.body).to eq("#{survey_url('sample-survey')}?token=#{token}")
    end
    
    it 'should generate 10 tokens and their urls if passed n=10' do
      SurveyToken.delete_all
      auth_login
      post :generate_token, {id: 'sample-survey', n: 10}
      expect(response).to have_http_status(:ok)
      expect(SurveyToken.count).to eq(10)
      SurveyToken.all.each do |t|
        expect(response.body).to match(t.token)
      end
    end
  end

  describe 'revoke_tokens' do
    it 'should fail unless the user authenticates as admin' do
      SurveyToken.generate('sample-survey')
      post :revoke_tokens, id: 'sample-survey'
      expect(response).to have_http_status(:unauthorized)
      expect(SurveyToken.count).to eq(1)
    end

    it 'should revoke all tokens for the application' do
      SurveyToken.delete_all
      SurveyToken.generate('sample-survey')
      SurveyToken.generate('sample-survey')
      expect(SurveyToken.count).to eq(2)

      auth_login
      post :revoke_tokens, {id: 'sample-survey'}
      expect(response).to have_http_status(:ok)
      expect(SurveyToken.count).to eq(0)
    end
  end
end
