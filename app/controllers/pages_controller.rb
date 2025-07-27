class PagesController < ApplicationController
  def about
    @about = Page.about
    @contact = Page.contact
  end

  def contact
    @contact = Page.contact
    @about = Page.about
  end
end
