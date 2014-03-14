#!/usr/bin/env rspec

require_relative "spec_helper"

require "scc_api/product_extensions"

describe SccApi::ProductExtensions do
  describe ".from_hash" do
    it "creates ProductExtensions from a SCC response" do
      response = [
        {
          "architecture_id" => nil,
          "created_at" => nil,
          "edition_id" => nil,
          "free" => false,
          "ibs_id" => nil,
          "id" => nil,
          "name" => "SLE12 SDK MOCK",
          "nnw_product_data" => nil,
          "product_class" => nil,
          "productdataid" => nil,
          "release_type" => nil,
          "updated_at" => nil,
          "zypper_name" => "SLE_SDK_MOCK"
        },
        {
          "architecture_id" => nil,
          "created_at" => nil,
          "edition_id" => nil,
          "free" => false,
          "ibs_id" => nil,
          "id" => nil,
          "name" => "SLE12 HAE MOCK",
          "nnw_product_data" => nil,
          "product_class" => nil,
          "productdataid" => nil,
          "release_type" => nil,
          "updated_at" => nil,
          "zypper_name" => "SLE_HAE_MOCK"
        }
      ]

      exts = SccApi::ProductExtensions.from_hash(response)
      expect(exts.extensions.size).to eq 2

      ext1 = exts.extensions.first
      expect(ext1.short_name).to eq("SLE12 SDK MOCK")
      expect(ext1.product_ident).to eq("SLE_SDK_MOCK")
      expect(ext1.free).to eq(false)
    end
  end
end
