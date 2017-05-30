# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PtosController, type: :controller do
  before :each do
    @pto = Pto.create(no_of_pto: 16)
    user = User.create(admin: true, name: 'test', email: 'test@test.com')
    allow_any_instance_of(PtosController).to receive(
      :current_user
    ).and_return(user)
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      it 'updates a existing pto count' do
        pto_param = { no_of_pto: 15 }
        expect { patch :update, params: pto_param }.not_to change(Pto, :count)
        expect(assigns(:pto).persisted?).to eq(true)
      end
    end

    context 'with invalid attributes' do
      it 'does not update the existing pto count' do
        pto_param = { pto: { no_of_pto: nil } }
        expect { patch :update, params: pto_param }.to_not change(Pto, :count)
        expect(assigns(:pto).errors.present?).to eq(true)
      end

      it 're-renders the :edit template with validation errors' do
        pto_param = { pto: { no_of_pto: nil }, id: @pto.id }
        patch :update, params: pto_param
        expect(assigns(:pto).errors.present?).to eq(true)
        expect(response).to render_template(:edit)
      end
    end
  end
end
