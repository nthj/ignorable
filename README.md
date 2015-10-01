[Donate to charity: water via Gittip](https://www.gittip.com/nthj/)

**Fork from [nthj/ignorable](https://github.com/nthj/ignorable/)**

The fork updates ignorable to be Rails 4.2 compatible

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

Tested on Rails 3.2, Rails 4.1.0, Rails 4.2.3
