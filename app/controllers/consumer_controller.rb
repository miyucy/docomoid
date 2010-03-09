class ConsumerController < ApplicationController
  layout nil

  def index
    params.each{ |k,v| Rails.logger.info "#{k} : #{v}" }
  end


  DOCOMO_OP_IDENTIFIER = "https://i.mydocomo.com"
  def start
    openid_request = consumer.begin(DOCOMO_OP_IDENTIFIER)
    if openid_request.send_redirect?(login_url, complete_url)
      redirect_to openid_request.redirect_url(login_url, complete_url)
    else
      render :text => openid_request.html_markup(login_url, complete_url)
    end
  end

  def complete
    parameters = params.reject{|k,v|request.path_parameters[k]}
    openid_request = consumer.complete(parameters, complete_url)
    case openid_request.status
    when OpenID::Consumer::SUCCESS
      flash[:success] = "Verification of #{openid_request.display_identifier}"
                        " succeeded."
    when OpenID::Consumer::FAILURE
      if openid_request.display_identifier
        flash[:error] = "Verification of #{openid_request.display_identifier}"
                        " failed: #{openid_request.message}"
      else
        flash[:error] = "Verification failed: #{openid_request.message}"
      end
    when OpenID::Consumer::CANCEL
      flash[:alert] = "OpenID transaction cancelled."
    when OpenID::Consumer::SETUP_NEEDED
      flash[:alert] = "Immediate request failed - Setup Needed"
    end
    redirect_to login_path
  end

  private

  def consumer
    @consumer ||= OpenID::Consumer.new(session, store)
  end

  def store
    @store ||= ActiveRecordStore.new
  end
end
