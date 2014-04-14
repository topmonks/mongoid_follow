class User
  include Mongoid::Document
  include Mongoid::Followee
  include Mongoid::Follower

  field :name

  def after_follow(followee)
    # after follower follows
  end

  def before_follow(follower)
    # after followee is followed
  end

  def before_unfollow(followee)
    # after follower unfollows
  end

  def after_unfollow(followee)
    # after follower unfollows
  end
end