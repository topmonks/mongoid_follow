module Mongoid
  module Followee
    extend ActiveSupport::Concern

    included do |base|
      after_destroy :reset_followers

      base.has_many :followers, :class_name => 'Follow', :as => :followee, :dependent => :destroy
    end

    # know if self is followed by model
    #
    # Example:
    # => @clyde.follower?(@bonnie)
    # => true
    def follower?(model, relation = "follow")
      self.followers.where(follower_type: model.class.name, :follower_id => model.id, relation: relation).exists?
    end

    # List all followers for given relation and klass
    #
    # Example:
    # => @bonnie.all_followers("follow", User)
    def all_followers(relation = "follow", klass = nil)
      all = followers.by_relation(relation)
      all = all.by_follower(klass) if klass

      all.collect do |f|
        f.follower
      end
    end

    private
    # unfollow by each follower
    def reset_followers
      Follow.where(:follower_id => self.id, follower_type: self.class.name).destroy_all
    end

  end
end
