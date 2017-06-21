# frozen_string_literal: true

require 'rails_helper'
RSpec.describe HomeController, type: :controller do
  describe 'GET #show' do
    before :each do
      get :show
    end

    it 'responds successfully with an HTTP 200 status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'redirects to oooperiods_path' do
      expect(response).to render_template(:show)
    end
  end
end
