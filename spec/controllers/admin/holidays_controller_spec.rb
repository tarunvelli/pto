# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::HolidaysController, type: :controller do
  before do
    allow_any_instance_of(Admin::HolidaysController).to receive(
      :admin_user
    ).and_return(true)
    @ooo_config = OOOConfig.create(leaves_count: 16,
                                   wfhs_count: 13,
                                   wfh_headsup_hours: 7.5,
                                   wfh_penalty_coefficient: 1,
                                   start_date: '2017-04-01',
                                   end_date: '2018-03-31')
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:holiday_params) do
        { date: '20170423', occasion: 'test' }
      end
      it 'creates a new holiday' do
        h_params = { oooconfig_id: @ooo_config.id, holiday: holiday_params }
        expect { post :create, params: h_params }
          .to change(Holiday, :count).by 1
        expect(assigns(:holiday).persisted?).to eq(true)
      end
    end

    context 'with invalid attributes' do
      let(:holiday_params) do
        { date: '20170423', occasion: nil }
      end

      it 'does not create the new holiday' do
        h_params = { oooconfig_id: @ooo_config.id, holiday: holiday_params }
        expect { post :create, params: h_params }
          .to_not change(Holiday, :count)
        expect(assigns(:holiday).persisted?).to eq(false)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    before do
      @holiday = @ooo_config.holidays.create(date: '20170723', occasion: 'testing')
    end

    context 'with valid attributes' do
      let(:holiday_params) do
        { date: '20170423', occasion: 'update' }
      end

      it 'updates a existing holiday' do
        h_params = { oooconfig_id: @ooo_config.id, holiday: holiday_params, id: @holiday.id }
        expect { patch :update, params: h_params }
          .not_to change(Holiday, :count)
        expect(assigns(:holiday).persisted?).to eq(true)
      end
    end

    context 'with invalid attributes' do
      let(:holiday_params) do
        { date: nil, occasion: nil }
      end

      it 'does not update the existing holiday' do
        h_params = { oooconfig_id: @ooo_config.id, holiday: holiday_params, id: @holiday.id }
        expect { patch :update, params: h_params }
          .not_to change(Holiday, :count)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'delete #destroy' do
    it 'deletes the existing holiday and check admin', skip_before: true do
      @holiday = @ooo_config.holidays.create(date: '20170723', occasion: 'testing')
      expect { delete :destroy, params: { oooconfig_id: @ooo_config.id, id: @holiday.id } }
        .to change(Holiday, :count).by(-1)
    end
  end
end
