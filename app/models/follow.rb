class Follow
  include Mongoid::Document
  include Mongoid::Timestamps

  field :relation, type: String

  belongs_to :follower, :polymorphic => true, index: true
  belongs_to :followee, :polymorphic => true, index: true

  validates :relation, presence: true
  validates :follower, presence: true
  validates :followee, presence: true

  scope :by_relation, ->(relation) { where(relation: relation) }
  scope :by_follower, ->(klass) { where(follower_type: klass.to_s) }
  scope :by_followee, ->(klass) { where(followee_type: klass.to_s) }

  index({relation: 1})
end
