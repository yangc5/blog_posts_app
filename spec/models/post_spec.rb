require 'spec_helper'

# Posts should have a title, content, belong to a user.

describe "Post" do
  before do
    @post = Post.create(title:'New Album', content: "I'm changing my album name again.")

    @user = User.create(username: "yeezy", email: "kanye@west.com", password: "kimverysecure")
  end

  # it "has title" do
  #   expect (@post.title).to eq('New Album')
  # end

  it "belongs to a user" do
    @user.posts << @post
    expect(@post.user).to eq(@user)
  end

end
