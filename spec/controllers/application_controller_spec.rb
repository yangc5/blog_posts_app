require 'spec_helper'
require 'pry'

describe ApplicationController do

  describe "Homepage" do
    it 'loads the homepage' do
      get '/'
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to Blog Post")
    end
  end

  describe "Signup Page" do

    it 'loads the signup page' do
      get '/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to posts index' do
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include("/posts")
    end

    it 'does not let a user sign up without a username' do
      params = {
        :username => "",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without an email' do
      params = {
        :username => "skittles123",
        :email => "",
        :password => "rainbows"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without a password' do
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => ""
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a logged in user view the signup page' do
      user = User.create(:username => "skittles123", :email => "skittles@aol.com", :password => "rainbows")
      params = {
        :username => "skittles123",
        :email => "skittles@aol.com",
        :password => "rainbows"
      }
      post '/signup', params
      session = {}
      session[:id] = user.id
      get '/signup'
      expect(last_response.location).to include('/posts')
    end
  end

  describe "login" do
    it 'loads the login page' do
      get '/login'
      expect(last_response.status).to eq(200)
    end

    it 'loads the posts index after login' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      # expect(last_response.body).to include("Welcome,")
    end

    it 'does not let user view login page if already logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      session = {}
      session[:id] = user.id
      get '/login'
      expect(last_response.location).to include("/posts")
    end
  end

  describe "logout" do
    it "lets a user logout if they are already logged in" do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      get '/logout'
      expect(last_response.location).to include("/login")

    end
    it 'does not let a user logout if not logged in' do
      get '/logout'
      expect(last_response.location).to include("/")
    end

    it 'does not load /posts if user not logged in' do
      get '/posts'
      expect(last_response.location).to include("/login")
    end

    it 'does load /posts if user is logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")


      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      expect(page.current_path).to eq('/posts')


    end
  end

  describe 'user index page' do
    it 'displays all users' do
      user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      user2 = User.create(:username => "jenny", :email => "example@aol.com", :password => "dogs")
      visit '/login'

      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      session = {}
      session[:id] = user1.id

      get "/users"

      expect(last_response.body).to include("becky567")
      expect(last_response.body).to include("jenny")
    end
  end



  describe 'user show page' do
    it 'shows all a single users posts' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      post1 = Post.create(:title => 'post1', :content => "posting!", :user_id => user.id)
      post2 = Post.create(:title => 'post2', :content => "post post post", :user_id => user.id)
      visit '/login'

      params = {
        :username => "becky567",
        :password => "kittens"
      }
      post '/login', params
      session = {}
      session[:id] = user.id

      get "/users/#{user.slug}"

      expect(last_response.body).to include("posting!")
      expect(last_response.body).to include("post post post")

    end
  end

  describe 'index action' do
    context 'logged in' do
      it 'lets a user view the posts index if logged in' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        post1 = Post.create(:title => 'post1', :content => "posting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        post2 = Post.create(:title => 'post2', :content => "look at this post", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/posts"
        expect(page.body).to include(post1.content)
        expect(page.body).to include(post2.content)
      end
    end


    context 'logged out' do
      it 'does not let a user view the posts index if not logged in' do
        get '/posts'
        expect(last_response.location).to include("/login")
      end
    end

  end



  describe 'new action' do
    context 'logged in' do
      it 'lets user view new post form if logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/posts/new'
        expect(page.status_code).to eq(200)

      end

      it 'lets user create a post if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/posts/new'
        fill_in(:title, :with => "post title")
        fill_in(:content, :with => "post!!!")
        click_button 'submit'

        user = User.find_by(:username => "becky567")
        post = Post.find_by(:title => "post title")
        expect(post).to be_instance_of(Post)
        expect(post.user_id).to eq(user.id)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user post from another user' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/posts/new'

        fill_in(:content, :with => "post!!!")
        click_button 'submit'

        user = User.find_by(:id=> user.id)
        user2 = User.find_by(:id => user2.id)
        post = Post.find_by(:title => "post title")
        expect(post).to be_instance_of(Post)
        expect(post.user_id).to eq(user.id)
        expect(post.user_id).not_to eq(user2.id)
      end

      it 'does not let a user create a blank post' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/posts/new'

        fill_in(:content, :with => "")
        click_button 'submit'

        expect(Post.find_by(:content => "")).to eq(nil)
        expect(page.current_path).to eq("/posts/new")

      end
    end

    context 'logged out' do
      it 'does not let user view new post form if not logged in' do
        get '/posts/new'
        expect(last_response.location).to include("/login")
      end
    end

  describe 'show action' do
    context 'logged in' do
      it 'displays a single post' do

        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        post = Post.create(:title => "boss post", :content => "i am a boss at posting", :user_id => user.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/posts/#{post.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Delete Post")
        expect(page.body).to include(post.content)
        expect(page.body).to include("Edit Post")
      end
    end

    context 'logged out' do
      it 'does not let a user view a post' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        post = Post.create(:title => "boss post", :content => "i am a boss at posting", :user_id => user.id)
        get "/posts/#{post.id}"
        expect(last_response.location).to include("/login")
      end
    end
  end


  end

  describe 'edit action' do
    context "logged in" do
      it 'lets a user view post edit form if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        post = Post.create(:title => "post", :content => "posting!", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/posts/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(post.content)
      end

      it 'does not let a user edit a post they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        post1 = Post.create(:title => "post", :content => "posting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        post2 = Post.create(:title => "watch me", :content => "look at this post", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        session = {}
        session[:user_id] = user1.id
        visit "/posts/#{post2.id}/edit"
        expect(page.current_path).to include('/posts')

      end

      it 'lets a user edit their own post if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        post = Post.create(:title => "post", :content => "posting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/posts/1/edit'

        fill_in(:title, :with => "love")
        fill_in(:content, :with => "i love posting")

        click_button 'submit'
        expect(Post.find_by(:title => "love")).to be_instance_of(Post)
        expect(Post.find_by(:title => "post")).to eq(nil)

        expect(page.status_code).to eq(200)
      end

      it 'does not let a user edit a text with blank content' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        post = Post.create(:title => "post", :content => "posting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/posts/1/edit'

        fill_in(:content, :with => "")

        click_button 'submit'
        expect(Post.find_by(:title => "love", :content => "i love posting")).to be(nil)
        expect(page.current_path).to eq("/posts/1/edit")

      end
    end

    context "logged out" do
      it 'does not load let user view post edit form if not logged in' do
        get '/posts/1/edit'
        expect(last_response.location).to include("/login")
      end
    end

  end

  describe 'delete action' do
    context "logged in" do
      it 'lets a user delete their own post if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        post = Post.create(:title => "post", :content => "posting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit 'posts/1'
        click_button "Delete Post"
        expect(page.status_code).to eq(200)
        expect(Post.find_by(:title => "post")).to eq(nil)
      end

      it 'does not let a user delete a post they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        post1 = Post.create(:title => "post", :content => "posting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        post2 = Post.create(:title => "watch me", :content => "look at this post", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "posts/#{post2.id}"
        click_button "Delete Post"
        expect(page.status_code).to eq(200)
        expect(Post.find_by(:title => "watch me")).to be_instance_of(Post)
        expect(page.current_path).to include('/posts')
      end

    end

    context "logged out" do
      it 'does not load let user delete a post if not logged in' do
        post = Post.create(:title => "post", :content => "posting!", :user_id => 1)
        visit '/posts/1'
        expect(page.current_path).to eq("/login")
      end
    end

  end


end
