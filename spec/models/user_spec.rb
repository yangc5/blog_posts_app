require 'spec_helper'

# Users should have a username, email, and password, and have many posts.

describe "User" do
  before do
    @user = User.create(:username => "John Doe", :email => "example@abc.com", :password => "validpw")

    @post1 = Post.create(:title => 'first post',  :content => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")

    @post2 = Post.create(:title => 'some thoughts', :content => "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
  end

  it "has a username" do
    expect(@user.username).to eq("John Doe")
  end

  it "has an email" do
    expect(@user.email).to eq("example@abc.com")
  end

  it "has a password" do
    expect(@user.password).to eq("validpw")
  end

  it "has many tweets" do
    @user.posts << @post1
    @user.posts << @post2
    expect(@user.posts).to include(@post1)
    expect(@user.posts).to include(@post2)
  end

  it "can slugify it's name" do
    expect(@user.slug).to eq("john-doe")
  end

  describe "Class methods" do
    it "given the slug can find a song" do
      slug = "john-doe"
      expect((User.find_by_slug(slug)).username).to eq("John Doe")
    end
  end


end
