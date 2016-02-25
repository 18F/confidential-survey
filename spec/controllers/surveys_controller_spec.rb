require 'rails_helper'

RSpec.describe SurveysController, type: :controller do
  describe 'show' do
    context 'for a survey using disposable tokens' do
      context 'for an active survey' do
        it 'should return a 200' do
          get :show, id: 'sample-survey'
          expect(response).to have_http_status(:ok)
        end
        
        it 'renders the show template' do
          get :show, id: 'sample-survey'
          expect(response).to render_template('show')
        end
        
        it' should instantiate a Markdown processor' do
          get :show, id: 'sample-survey'
          expect(assigns(:md)).to_not be_nil
        end

        it 'should not destroy the token'
      end

      context 'for a nonexistant survey' do
        it 'should return a 404' do
          get :show, id: 'blah'
          expect(response).to have_http_status(:not_found)
        end

        it 'should not destroy the token'
      end

      context 'for an inactive survey' do
        it 'should return a 404' do
          expect_any_instance_of(Survey).to receive(:active?).and_return(false)
          get :show, id: 'sample-survey'
          expect(response).to have_http_status(:not_found)
          end

        it 'should not destroy the token'
      end

      context 'when the user does not present a token' do
        it 'should return a 404'
      end
    end
    
    context 'for a survey using HTTP authentication' do
      # FIXME
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
    context 'for a form using token-based authentication' do
      context 'for an active survey' do
        it 'should redirect to the Thank You page'
        it 'should record the responses'
        it 'should destroy the token'
        it 'should not allow replays with the same token'
      end

      context 'for an inactive survey' do
        it 'should return a 404'
        it 'should not record the record responses'
        it 'should not destroy the token'
      end

      context 'when the survey is not found' do
        it 'should return a 404'
      end

      context 'when the user does not present a token' do
        it 'should return a 404'
        it 'should not record the survey responses'
      end
    end
  end
end
