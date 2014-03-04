class Follow
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ff_type
  field :ff_id

  belongs_to :follower, :polymorphic => true
  belongs_to :followee, :polymorphic => true

  def ff_object
    ff_type.constantize.find(ff_id)
  end
end