module Mongoid
  module Follower
    extend ActiveSupport::Concern

    included do |base|
      after_destroy :reset_followees

      base.has_many :followees, :class_name => 'Follow', :as => :follower, :dependent => :destroy
    end

    # follow a model
    #
    # Example:
    # => @bonnie.follow!(@clyde)
    def follow!(model, relation = "follow")
      if self != model && !self.follows?(model, relation)
        self.before_follow(model) if self.respond_to?('before_follow')
        self.followees.create!(:followee_type => model.class.name, :followee_id => model.id, relation: relation)
        self.after_follow(model) if self.respond_to?('after_follow')
        return true
      else
        return false
      end
    end

    # unfollow a model
    #
    # Example:
    # => @bonnie.unfollow!(@clyde)
    def unfollow!(model, relation = "follow")
      if self != model && self.follows?(model, relation)
        self.before_unfollow(model) if self.respond_to?('before_unfollow')
        self.followees.where(:followee_type => model.class.name, :followee_id => model.id, relation: relation).destroy
        self.after_unfollow(model) if self.respond_to?('after_unfollow')
        return true
      else
        return false
      end
    end

    # List all followees for given relation and klass
    #
    # Example:
    # => @bonnie.all_followees("follow", User)
    def all_followees(relation = "follow", klass = nil)
      all = followees.by_relation(relation)
      all = all.by_followee(klass) if klass

      all.collect do |f|
        f.followee
      end
    end


    # know when started following
    #
    # Example:
    # => @bonnie.followed_since(@clyde)
    # => Time or nil
    def followed_since(model, relation = "follow")
      self.followees.where(:followee_type => model.class.name, :followee_id => model.id, relation: relation).first.try(:created_at)
    end

    # know if self is already following model
    #
    # Example:
    # => @bonnie.follows?(@clyde)
    # => true
    def follows?(model, relation = "follow")
      self.followees.where(followee_id: model.id, followee_type: model.class.name, relation: relation).exists?
    end

    private
    # unfollow each followee
    def reset_followees
      Follow.where(:followee_id => self.id, followee_type: self.class.name).destroy_all
    end

  end
end
