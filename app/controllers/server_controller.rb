class ServerController < ApplicationController
  layout nil

  def xrds
    yadis = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns="xri://$xrd*($v*2.0)">
  <XRD>
    <Service priority="0">
      <Type>#{OpenID::OPENID_IDP_2_0_TYPE}</Type>
      <URI>#{url_for(:controller => 'server', :only_path => false)}</URI>
    </Service>
  </XRD>
</xrds:XRDS>
EOS
    response.headers['content-type'] = 'application/xrds+xml'
    render :text => yadis
  end
end
