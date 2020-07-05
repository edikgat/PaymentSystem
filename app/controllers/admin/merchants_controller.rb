# frozen_string_literal: true

class Admin
  class MerchantsController < BaseController
    before_action :set_merchant, only: %i[show edit update destroy]
    def index
      @merchants = Merchant.all
    end

    def show; end

    def new
      @merchant = Merchant.new
    end

    def edit; end

    def create
      @merchant = Merchant.new(merchant_params)
      respond_to do |format|
        if @merchant.save
          format.html { redirect_to admin_merchant_path(@merchant), notice: 'Merchant was successfully created.' }
        else
          format.html { render :new }
        end
      end
    end

    def update
      respond_to do |format|
        if @merchant.update(merchant_params)
          format.html { redirect_to admin_merchant_path(@merchant), notice: 'Merchant was successfully updated.' }
        else
          format.html { render :edit }
        end
      end
    end

    def destroy
      respond_to do |format|
        if @merchant.allow_destroy?
          @merchant.destroy
          format.html { redirect_to(admin_merchants_path, notice: 'Merchant was successfully destroyed.') }
        else
          format.html do
            redirect_to(
              admin_merchants_path,
              notice: 'Merchant should not have transactions, to be destroyed.'
            )
          end
        end
      end
    end

    private

    def set_merchant
      @merchant = Merchant.find(params[:id])
    end

    def merchant_params
      params.require(:merchant).permit(
        :name,
        :description,
        :email,
        :status,
        :password_confirmation,
        :password
      )
    end
  end
end
