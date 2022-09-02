class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:update, :edit]
  # ユーザーの編集画面へのURLを直接入力された場合にはメッセージを表示してユーザー詳細画面へリダイレクトさせます。
  before_action :ensure_guest_user, only: [:edit]

  def show
    @user = User.find(params[:id])
    @books = @user.books
    @book = Book.new

    @book_count = []
    # 6.downto(0)は、0..6の逆
    for num in 6.downto(0) do
    # append or << で要素の追加
    # 0番目に6日前の投稿数が入る
      @book_count.append(Book.book_created(num, current_user))
    end
  end

  def index
    @users = User.all
    @book = Book.new
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "You have updated user successfully."
    else
      render "edit"
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to user_path(current_user)
    end
  end

  # ユーザーの編集画面へのURLを直接入力された場合にはメッセージを表示してユーザー詳細画面へリダイレクトさせます。
  def ensure_guest_user
    @user = User.find(params[:id])
    if @user.name == "guestuser"
      redirect_to user_path(current_user), notice: "ゲストユーザーはプロフィール画面に遷移できません"
    end
  end
end
