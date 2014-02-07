#!/usr/bin/env rspec

require_relative "spec_helper"

require "scc_api/product_services"

describe SccApi::ProductServices do
  describe ".from_hash" do
    it "creates ProductServices from a SCC response hash" do
      # see https://github.com/SUSE/happy-customer/wiki/Connect-API#wiki-response-3
      hash = {
        "sources" => {
          "SUSE_Linux_Enterprise_Server" => "https://example.com"
        },
        "norefresh" => [
          "SLES12-Pool"
        ],
        "enabled" => [
          "SLES12-Pool",
          "SLES12-Updates",
        ]
      }
      
      services = SccApi::ProductServices.from_hash(hash)

      expect(services.services.size).to eq 1
      expect(services.services.first.name).to eq "SUSE_Linux_Enterprise_Server"
      expect(services.services.first.url).to eq URI("https://example.com")

      expect(services.norefresh_repos).to eq [ "SLES12-Pool" ]
      expect(services.enabled_repos).to eq [ "SLES12-Pool", "SLES12-Updates" ]
    end
  end
end
