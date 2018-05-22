# spec/controllers/contacts_controller_spec.rb
require 'spec_helper'

describe ProposalsController do
  describe "GET #index" do
    it "populates an array of proposals"
    it "renders the :index view"
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new proposal in the database"
      it "redirects to the home page"
    end

    context "with invalid attributes" do
      it "does not save the new proposal in the database"
      it "re-renders the :new template"
    end
  end
end
