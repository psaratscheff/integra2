class PagesController < ApplicationController
  def index
    # render "pages/index"
  end



  def post_facebook
    productTitle = params[:productTitle]
    mensaje = params[:message]
    name = params[:name]
    case productTitle
    when "Avena"
      link = "http://integra2.ing.puc.cl/images/products/avena.png";
    when "Cuero"
      link = "http://integra2.ing.puc.cl/images/products/cuero.png";
    when "Algodon"
      link = "http://integra2.ing.puc.cl/images/products/algodon.png";
    when "Lino"
      link = "http://integra2.ing.puc.cl/images/products/lino.png";
    when "Huevo"
      link = "http://integra2.ing.puc.cl/images/products/huevos.png";
    end

    twittear(productTitle, name)

    # @user = Koala::Facebook::API.new('EAACEdEose0cBALPUxqgCjOKqhSpbhts290mbsZBd1YrsxsDNRKmmchQRnwCNtFNeNOC2290hQwLuI2Af3GB0muFgwZARyoyo15XvcIoIETZA1nfoxrmsPlLAcZAbNW28cQxvSD2MlP8wDvSya37J0D6SbKfsSshhuhVOPcMXaAZDZD')
    # page_access_token = @user.get_connections('me', 'accounts').first['EAACEdEose0cBALPUxqgCjOKqhSpbhts290mbsZBd1YrsxsDNRKmmchQRnwCNtFNeNOC2290hQwLuI2Af3GB0muFgwZARyoyo15XvcIoIETZA1nfoxrmsPlLAcZAbNW28cQxvSD2MlP8wDvSya37J0D6SbKfsSshhuhVOPcMXaAZDZD'] #this gets the users first page.
    # @page = Koala::Facebook::API.new(page_access_token)
    @page = Koala::Facebook::API.new('EAADoyVItZAOoBAOhWV8WhIW2o17TC26g4XvgCijuqKp6qJVdjWn6btK0D8SwZAuuNSpGEN7LyLG9eznIRUy9wgGoM8piQLGuvWQodjwDahmfoZAXsXJQGh1pE9cogn1W6t3ZCLzWT3oOUhfeZCxAyg8qdrwalUS8ZD')
    @page.put_object("me", "feed", :message => name + " nos cuenta que su producto favorito es " + productTitle + "! En sus palabras: ''" + mensaje +"''", :link => link,
    :picture => link, :name => productTitle, :caption => productTitle, :description => "")

    redirect_to contact_path

  end



  def twittear(productTitle, name)
    puts productTitle
    case productTitle
    when "Avena"
      img = open("public/images/products/avena.png")
    when "Cuero"
      img = open("public/images/products/cuero.png")
    when "Algodon"
      img = open("public/images/products/algodon.png")
    when "Lino"
      img = open("public/images/products/lino.png")
    when "Huevo"
      img = open("public/images/products/huevos.png")
    end

    # img = open("public/images/logo.png")
    if img.is_a?(StringIO)
      ext = File.extname(url)
      name = File.basename(url, ext)
      Tempfile.new([name, ext])
    else
      img
    end
    $client.update_with_media('Para ' + name + ", "+ productTitle + ' es lo mejor!!', img)
  end



end
