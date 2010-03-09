class ConsumerController < ApplicationController
  layout nil

  def index
    response.headers['X-XRDS-Location'] = url_for(:controller => 'server', :action => 'xrds', :only_path => false)
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
    #Rails.logger.info parameters.inspect
    #Rails.logger.info complete_url.inspect
    openid_request = consumer.complete(parameters, complete_url)
    #Rails.logger.info consumer.inspect
    #Rails.logger.info openid_request.inspect
    case openid_request.status
    when OpenID::Consumer::SUCCESS
      flash[:success] = "Verification of #{openid_request.display_identifier}"
                        " succeeded."
      user_attr(params["openid.identity"], params["openid.response_nonce"])
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

  def user_attr identity_url, nonce
    require 'uri'
    require 'cgi'
    require 'open-uri'
    uri = URI.parse('https://i.mydocomo.com/api/imode/g-info')
    param = { }
    param['ver'] = '1.0'
    param['openid'] = identity_url
    param['nonce'] = nonce
    param['GUID'] = ''
    param['UA'] = ''
    uri.query = param.map{|k,v| "#{k}=#{CGI.escape(v)}"}.join("&")
    raw = open(uri.to_s).read
    Rails.logger.info raw
    attr = {}
    raw.chomp.split(/\r\n/).each do |p,v|
      attr[p] = v
    end
    Rails.logger.info attr.inspect
    attr
  end
end
