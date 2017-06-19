# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HolidaysController, type: :controller do
  before :each do |example|
    unless example.metadata[:skip_before]
      allow_any_instance_of(HolidaysController).to receive(
        :admin_user
      ).and_return(true)
    end
    @holiday = Holiday.create(date: '20170723', occasion: 'testing')
  end

  describe 'GET #index' do
    before :each do
      get :index
    end

    it 'responds successfully with an HTTP 200 status code' do
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'assigns @holidays' do
      expect(assigns(:holidays)).to eq([@holiday])
    end

    it 'renders the #index view' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    before :each do
      get :new
    end

    it 'assigns a new Leave to @holiday' do
      expect(assigns(:holiday).new_record?).to eq(true)
    end

    it 'renders the :new template' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:holiday_params) do
        { holiday: { date: '20170423', occasion: 'test' } }
      end
      it 'creates a new holiday' do
        expect { post :create, params: holiday_params }
          .to change(Holiday, :count).by 1
        expect(assigns(:holiday).persisted?).to eq(true)
      end

      it 'redirects to the holiday#index page' do
        post :create, params: holiday_params
        expect(response).to redirect_to holidays_url
      end
    end

    context 'with invalid attributes' do
      let(:holiday_params) do
        { holiday: { date: '20170423', occasion: nil } }
      end

      it 'does not create the new holiday' do
        expect { post :create, params: holiday_params }
          .to_not change(Holiday, :count)
        expect(assigns(:holiday).persisted?).to eq(false)
      end

      it 're-renders the :new template with validation errors' do
        post :create, params: { holiday: holiday_params }
        expect(assigns(:holiday).errors.present?).to eq(true)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      let(:holiday_params) do
        { holiday: { date: '20170423', occasion: 'update' }, id: @holiday.id }
      end

      it 'updates a existing holiday' do
        expect { patch :update, params: holiday_params }
          .not_to change(Holiday, :count)
        expect(assigns(:holiday).persisted?).to eq(true)
      end

      it 'redirects to the holiday#index page' do
        patch :update, params: holiday_params
        expect(response).to redirect_to holidays_url
      end
    end

    context 'with invalid attributes' do
      let(:holiday_params) do
        { holiday: { date: '20170423', occasion: nil }, id: @holiday.id }
      end

      it 'does not update the existing holiday' do
        expect { patch :update, params: holiday_params }
          .to_not change(Holiday, :count)
        expect(assigns(:holiday).errors.present?).to eq(true)
      end

      it 're-renders the :edit template with validation errors' do
        patch :update, params: holiday_params
        expect(assigns(:holiday).errors.present?).to eq(true)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'delete #destroy' do
    it 'deletes the existing holiday and check admin', skip_before: true do
      user = User.new(admin: true)
      allow_any_instance_of(HolidaysController).to receive(
        :current_user
      ).and_return(user)
      holiday = { id: @holiday.id }
      expect { delete :destroy, params: holiday }
        .to change(Holiday, :count).by(-1)
    end
  end
end
