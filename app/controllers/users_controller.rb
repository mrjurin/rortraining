class UsersController < ApplicationController
    before_action :set_user, only: [:edit,:update,:show]
    before_action :require_user, except: [:index,:new,:show,:create]
    before_action :require_same_user, only: [:edit,:update,:destroy]
    before_action :require_admin, only:[:destroy]
    
    def new
        @user = User.new
    end
    
    def create
        @user = User.new(user_params)
        if @user.save
            session[:user_id]=@user.id
            flash[:notice] = "Welcome to the alpha blog #{@user.username}"
            redirect_to user_path(@user)
        else
            render 'new'
        end
    end
    
    def edit
        @user= User.find(params[:id])
    end
    
    def update
       
       
       if @user.update(user_params)
           flash[:notice] = "Your account updateed successfully"
           redirect_to articles_path
       else
        render 'edit'    
       end
        
    end
    
    
    def show
        
        @user_articles=@user.articles.paginate(page:params[:page],per_page:3)

    end
    
    def index
        @users=User.paginate(page:params[:page],per_page:3)
    end
    
    
    def destroy
        @user = User.find(params[:id])
        
        if @user.id != current_user.id
            @user.destroy
            flash[:notice] = "User and all articles successfully deleted"
            redirect_to users_path
        else
            flash[:notice]="Cannot delete yourself"
            redirect_to users_path
        end
        
        
    end
    
    
    private
        def user_params
            params.require(:user).permit(:username,:email,:password)
        end
        
        
        def set_user
            @user= User.find(params[:id])
        end
        
        def require_same_user
            if current_user !=@user && !current_user.admin?
                flash[:notice] = "you can only edit or update your own profile"
                redirect_to root_path
            end
        end
        
        def require_admin
            if logged_in? && !current_user.admin?
                flash[:notice] = "Only admin user can perform that actions"
                redirect_to user_path
            end
        end
    
end