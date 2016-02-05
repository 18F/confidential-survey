require 'rails_helper'

RSpec.describe SurveysController, type: :controller do
  describe 'show' do
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

      it 'should not set a session cookie' do
        get :show, id: 'sample-survey'
        expect(session).to be_empty
      end
    end

    context 'for a nonexistant survey' do
      it 'should return a 404' do
        get :show, id: 'blah'
        expect(response).to have_http_status(:not_found)
      end

      it 'should not set a session cookie' do
        get :show, id: 'blah'
        expect(session).to be_empty
      end
    end

    context 'for an inactive survey' do
      it 'should return a 404' do
        expect_any_instance_of(Survey).to receive(:active?).and_return(false)
        get :show, id: 'sample-survey'
        expect(response).to have_http_status(:not_found)
      end

      it 'should not set a session cookie' do
        get :show, id: 'sample-survey'
        expect(session).to be_empty
      end
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

      it 'should not set a session cookie' do
        get :show, id: 'sample-survey', format: 'json'
        expect(session).to be_empty
      end
    end
  end
end
