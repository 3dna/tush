# Tush

Tush is a gem for migrating database rows between applications with ActiveRecord,
while preserving *all associations.*

## Installing Tush

If you're using Rails, just add the following to your Gemfile:
```
gem 'tush'
```

## Tush Exports

Data is fed to the importer by first creating a JSON export of your
rows. This is done by feeding your ActiveRecord model instances to the
exporter:
```ruby
model_instance1 = ActiveRecordModel.create
json_export = Tush::Exporter.new([model_instance1]).export_json
```
This will immediately scan each input model instance and recursively
add any associated models to the export. If `model_instance1` has an
association with `model_instance2` and `model_instance2` has an
association with `model_instance3`, *all 3* model instances will be
included in the export.

## Tush Imports

Using a JSON export created with `Tush::Exporter`, we can initialize
an import, usually in a different application that shares the same
ActiveRecord models,like this:
```ruby
importer = Tush::Importer.new_from_json(json_export)
```
When we want to create the new models, and therefore importing all
exported rows from our other application, we run
```ruby
importer.create_models!
```
And to update all foreign keys to be accurate in the new application,
run
```ruby
importer.update_foreign_keys!
```

## Contributing to Tush

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Tush has *100% test coverage*; keep it that way.

## Copyright

Copyright (c) 2013 NationBuilder. See LICENSE.txt for
further details.
