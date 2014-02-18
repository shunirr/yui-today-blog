# -*- encoding: utf-8 -*-
class RenameDuplicates < ActiveRecord::Migration
  def self.up
    rename_column :duplicates, :url, :identify
  end

  def self.down
    rename_column :duplicates, :identify, :url
  end
end
