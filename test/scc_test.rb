#!/usr/bin/env rspec

require_relative "spec_helper"

describe "SccApi" do
  # check the global lib/scc_api.rb file
  it "global require succeeds" do
    expect(require "scc_api").to eq true
  end
end
