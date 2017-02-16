class TalentController < ApplicationController
  # GET /talent
  def index
    @skip_container = true
    @talent_form = TalentForm.new(OpenStruct.new)
    render layout: 'application_v2'
  end

  # POST /talent/contact
  def contact
    @talent_form = TalentForm.new(OpenStruct.new)

    # TODO: Implement recaptcha for talent form.
    # Check recaptcha first.
    # unless verify_recaptcha(model: @contact_form)
    #   render 'contact'
    #   return
    # end

    if @talent_form.validate(talent_form_params)
      @talent_form.send_mail
      flash[:success] = "An email with your query has been sent to help@sv.co. We'll get back to you as soon as we can."
      redirect_to talent_path
    else
      flash.now[:error] = 'Please make sure that you filled out all required fields in the form.'
      @skip_container = true
      @show_form = true
      render 'index'
    end
  end

  private

  def talent_form_params
    params.require(:talent).permit(:name, :email, :mobile, :organization, :website, query_type: [])
  end
end
