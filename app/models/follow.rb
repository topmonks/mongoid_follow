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
  index({follower_id: 1, follower_type: 1, relation: 1}, { unique: true, drop_dups: true })
  index({followee_id: 1, follower_type: 1, relation: 1}, { unique: true, drop_dups: true })
  index({followee_id: 1, follower_type: 1, follower_id: 1, relation: 1}, { unique: true, drop_dups: true })
end
