class SearchesController < ApplicationController
  before_action :authenticate_user!

  def search_result
    @range = params[:range]

    if @range == "User"

      @users = User.looks(params[:search], params[:word])
    else
      @books = Book.looks(params[:search], params[:word])
    end
  end
end


#一部抜粋
  def search
    @user = User.find(params[:user_id])
    @books = @user.books 
    @book = Book.new
    if params[:created_at] == ""
      @search_book = "日付を選択してください"#①
    else
      create_at = params[:created_at]
      @search_book = @books.where(['created_at LIKE ? ', "#{create_at}%"]).count#②
    end
  end