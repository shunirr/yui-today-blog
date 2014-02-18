# -*- encoding: utf-8 -*-
class CreateDuplicates < ActiveRecord::Migration
  def self.up
    create_table :duplicates do |t|
      t.string :url
      t.timestamps
    end
  end

  def self.down
    drop_table :duplicates
  end
end
