require 'rails_helper'

RSpec.describe SurveysController, type: :controller do
  describe 'show' do
    context 'for an survey using disposable tokens' do
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
      context 'when the user provides the correct credentials' do
        before do
          http_login('survey', 'survey')
        end

        it 'should return a 200' do
          get :show, id: 'auth-survey'
          expect(response).to have_http_status(:ok)
        end

        it 'renders the show template' do
          get :show, id: 'auth-survey'
          expect(response).to render_template('show')
        end

        it' should instantiate a Markdown processor' do
          get :show, id: 'auth-survey'
          expect(assigns(:md)).to_not be_nil
        end
      end

      context 'for an inactive survey' do
        it 'should return a 404 Not Found' do
          expect_any_instance_of(Survey).to receive(:active?).and_return(false)
          get :show, id: 'auth-survey'
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the user presents incorrect credentials' do
        it 'should return a 401 Unauthorized' do
          http_login('wrong', 'wronger')
          get :show, id: 'auth-survey'
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'for a survey with an unknown type of access' do
      it 'should raise a server error' do
        expect_any_instance_of(Survey).to receive(:access_params).and_return(type: 'foobar')
        get :show, id: 'sample-survey'
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'survey_json' do
    context 'for an active survey' do
      it 'should return a 200 OK' do
        get :survey_json, id: 'sample-survey'
        expect(response).to have_http_status(:ok)
      end
      
      it 'should include not include questions and counts' do
        json = nil
        get :survey_json, id: 'sample-survey'

        expect { json = JSON.parse(response.body) }.to_not raise_error

        expect(json['id']).to eq('sample-survey')
        expect(json['title']).to eq('Ice Cream Survey')
        expect(json['questions']).to be_nil
        expect(json['intersections']).to be_nil
      end
    end

    context 'for an inactive survey' do
      it 'should return a 200 OK' do
        expect_any_instance_of(Survey).to receive(:active?).and_return(false)
        get :survey_json, id: 'sample-survey'
        expect(response).to have_http_status(:ok)
      end
      
      it 'should include questions and counts' do
        expect_any_instance_of(Survey).to receive(:active?).and_return(false)
        get :survey_json, id: 'sample-survey'
        json = nil
        expect { json = JSON.parse(response.body) }.to_not raise_error

        expect(json['id']).to eq('sample-survey')
        expect(json['title']).to eq('Ice Cream Survey')
        expect(json['questions']).to_not be_nil
        expect(json['questions'].first['key']).to eq('ice-cream')
        expect(json['intersections']).to_not be_nil
      end
    end

    context 'if a survey is not found' do
      it 'should return a 404' do
        get :survey_json, id: 'foobar'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
  
  describe 'submit' do
    let(:survey) { Survey.new('sample-survey') }
    let(:token) { SurveyToken.generate('sample-survey') }
    let(:survey_id) { 'sample-survey' }
    let(:params) do
      {'survey' => {'name' => 'Jacob Harris',
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
          expect(SurveyToken.valid?(survey.survey_id, token)).to be_truthy
          post :submit, params
          expect(SurveyToken.valid?(survey.survey_id, token)).to be_falsey
        end

        it 'should not allow replays with the same token' do
          expect(SurveyToken.valid?(survey.survey_id, token)).to be_truthy
          post :submit, params
          t1 = survey.tally_for('ice-cream', 'yes')
          expect(t1).to eq(1)

          expect(SurveyToken.valid?(survey.survey_id, token)).to be_falsey

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
          expect(SurveyToken.valid?(survey.survey_id, token)).to be_truthy
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
      get :generate_token, id: 'sample-survey'
      expect(response).to have_http_status(:ok)
      token = SurveyToken.first
      expect(token).to_not be_nil
      expect(response.body).to eq("#{survey_url('sample-survey')}?token=#{token}\n")
    end

    it 'should generate 10 tokens and their urls if passed n=10' do
      SurveyToken.delete_all
      auth_login
      post :generate_token, id: 'sample-survey', n: 10
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
      post :revoke_tokens, id: 'sample-survey'
      expect(response).to have_http_status(:ok)
      expect(SurveyToken.count).to eq(0)
    end
  end
end
