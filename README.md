[Donate to charity: water via Gittip](https://www.gittip.com/nthj/)

ignorable
=========

Ignore columns in ActiveRecord 

Installation
============

Add this to your Gemfile: 
  
    gem 'ignorable'

Usage
=====

    class Topic < ActiveRecord::Base
       ignore_columns :attributes, :class, :meta_column_used_by_another_app
    end

Rails Versions
==============

Tested on Rails 3.2, Rails 4.1.0. 
