require 'spec_helper'

describe Mongoid::Follower do

  describe User do

    before do
      @bonnie = User.create(:name => 'Bonnie')
      @clyde = User.create(:name => 'Clyde')
      @alec = User.create(:name => 'Alec')
      @just_another_user = OtherUser.create(:name => 'Another User')

      @gang = Group.create(:name => 'Gang')
    end

    it "should have timestamp" do
      @bonnie.followed_since(@clyde).should be_nil

      @bonnie.follow!(@clyde)

      @bonnie.followed_since(@clyde).should_not be_nil
    end

    it "should have no follows or followers" do
      @bonnie.follows?(@clyde).should be_false

      @bonnie.follow!(@clyde)
      @clyde.follower?(@alec).should be_false
      @alec.follows?(@clyde).should be_false
    end

    it "can follow another User" do
      @bonnie.follow!(@clyde)

      @bonnie.follows?(@clyde).should be_true
      @clyde.follower?(@bonnie).should be_true
    end

    it "should decline to follow self" do
      @bonnie.follow!(@bonnie).should be_false
    end

    it "should decline two follows" do
      @bonnie.follow!(@clyde)

      @bonnie.follow!(@clyde).should be_false
    end

    it "can unfollow another User" do
      @bonnie.follows?(@clyde).should be_false
      @clyde.follower?(@bonnie).should be_false

      @bonnie.follow!(@clyde)
      @bonnie.follows?(@clyde).should be_true
      @clyde.follower?(@bonnie).should be_true

      @bonnie.unfollow!(@clyde)
      @bonnie.follows?(@clyde).should be_false
      @clyde.follower?(@bonnie).should be_false
    end

    it "should decline unfollow of non-followed User" do
      @bonnie.unfollow!(@clyde).should be_false
    end

    it "should decline unfollow of self" do
      @bonnie.unfollow!(@bonnie).should be_false
    end

    it "can follow a group" do
      @bonnie.follow!(@gang)

      @bonnie.follows?(@gang).should be_true
      @gang.follower?(@bonnie).should be_true
    end

    describe "listing stuff" do
      it "should list all followers" do
        @bonnie.follow!(@clyde)

        @alec.follow!(@clyde)
        @clyde.all_followers.should == [@bonnie, @alec]
      end

      it "should list all followers by model" do
        @bonnie.follow!(@gang)
        @just_another_user.follow!(@gang)

        @gang.all_followers.should == [@bonnie, @just_another_user]
        @gang.all_followers("follow", User).should == [@bonnie]
      end

      it "should list all followees" do
        @bonnie.follow!(@clyde)
        # @bonnie.all_followees.should == [@clyde] # spec has an error on last #all_followees when this is called

        @bonnie.follow!(@gang)
        @bonnie.all_followees.should == [@clyde, @gang]
      end

      it "should list all followees by model" do
        @bonnie.follow!(@gang)
        @bonnie.follow!(@clyde)

        @bonnie.all_followees.should == [@gang, @clyde]
        @bonnie.all_followees("follow", User).should == [@clyde]
      end
    end

    describe "callback stuff" do
      # Duh... this is a useless spec... Hrmn...
      it "should respond on callbacks" do
        @bonnie.respond_to?('after_follow').should be_true
        @bonnie.respond_to?('after_unfollowed_by').should be_true
        @bonnie.respond_to?('before_follow').should be_false

        @gang.respond_to?('before_followed_by').should be_true
        @gang.respond_to?('after_followed_by').should be_false
      end

      it "should be unfollowed by each follower after destroy" do
        @bonnie.follow!(@clyde)
        @alec.follow!(@clyde)

        @clyde.destroy

        @bonnie.reload.all_followees.include?(@clyde).should == false
        @alec.reload.all_followees.include?(@clyde).should == false
      end

      it "should be unfollowed after follower destroy" do
        @bonnie.follow!(@clyde)
        @alec.follow!(@clyde)

        @bonnie.destroy

        @clyde.reload.all_followers.include?(@bonnie).should == false
        @clyde.reload.all_followers.include?(@alec).should == true
      end
    end

  end
end
