require 'test_helper'

class VersionableTest < Test::Unit::TestCase
  class ParentClass
    include ActiveMerchant::Versionable
  end

  class DummyClass < ParentClass
  end

  class FakeClass < ParentClass
  end

  class DummyChildClass < DummyClass
  end

  def setup
    @dummy_instance = DummyClass.new
    @fake_instance = FakeClass.new
    @dummy_child_instance = DummyChildClass.new
  end

  def test_class_can_set_and_fetch_default_version
    DummyClass.version('1.0')
    assert_equal '1.0', DummyClass.fetch_version, 'Class should return the correct version'
  end

  def test_class_can_set_and_fetch_custom_feature_version
    DummyClass.version('2.0', :custom_api)
    DummyClass.version('v2', :some_feature)
    assert_equal '2.0', DummyClass.fetch_version(:custom_api), 'Class should return the correct version'
    assert_equal 'v2', DummyClass.fetch_version(:some_feature), 'Class should return the correct version'
  end

  def test_instance_can_fetch_default_version
    DummyClass.version('v3')
    assert_equal 'v3', @dummy_instance.fetch_version, 'Instance should return the correct version'
  end

  def test_instance_can_fetch_custom_feature_version
    DummyClass.version('v4', :custom_api)
    DummyClass.version('4.0', :some_feature)
    assert_equal 'v4', @dummy_instance.fetch_version(:custom_api), 'Instance should return the correct version'
    assert_equal '4.0', @dummy_instance.fetch_version(:some_feature), 'Instance should return the correct version'
  end

  def test_fetch_version_returns_nil_for_unset_feature
    assert_nil DummyClass.fetch_version(:nonexistent_feature), 'Class should return nil for an unset feature'
    assert_nil @dummy_instance.fetch_version(:nonexistent_feature), 'Instance should return nil for an unset feature'
  end

  def test_classes_dont_share_versions
    # Default key
    DummyClass.version('1.0')
    FakeClass.version('2.0')
    DummyChildClass.version('3.0')

    # Custom key :some_feature
    DummyChildClass.version('v5', :some_feature)
    FakeClass.version('v3', :some_feature)
    DummyClass.version('v4', :some_feature)

    assert_equal '1.0', DummyClass.fetch_version, 'Class should return the correct version'
    assert_equal 'v4', DummyClass.fetch_version(:some_feature), 'Class should return the correct version'
    assert_equal '2.0', FakeClass.fetch_version, 'Class should return the correct version'
    assert_equal 'v3', FakeClass.fetch_version(:some_feature), 'Class should return the correct version'
    assert_equal '3.0', DummyChildClass.fetch_version, 'Class should return the correct version'
    assert_equal 'v5', DummyChildClass.fetch_version(:some_feature), 'Class should return the correct version'
  end

  def test_instances_dont_share_versions
    # Default key
    DummyClass.version('1.0')
    FakeClass.version('2.0')
    DummyChildClass.version('3.0')

    # Custom key :some_feature
    DummyChildClass.version('v5', :some_feature)
    FakeClass.version('v3', :some_feature)
    DummyClass.version('v4', :some_feature)

    assert_equal '1.0', @dummy_instance.fetch_version, 'Instance should return the correct version'
    assert_equal 'v4', @dummy_instance.fetch_version(:some_feature), 'Instance should return the correct version'
    assert_equal '2.0', @fake_instance.fetch_version, 'Instance should return the correct version'
    assert_equal 'v3', @fake_instance.fetch_version(:some_feature), 'Instance should return the correct version'
    assert_equal '3.0', @dummy_child_instance.fetch_version, 'Instance should return the correct version'
    assert_equal 'v5', @dummy_child_instance.fetch_version(:some_feature), 'Instance should return the correct version'
  end

  def test_subclass_inherits_parent_version
    ParentClass.version('9.0', :inherited_feature)
    assert_equal '9.0', DummyClass.fetch_version(:inherited_feature), 'Subclass should fall back to the parent version'
    assert_equal '9.0', DummyChildClass.fetch_version(:inherited_feature), 'Grandchild should fall back to the parent version'
    assert_equal '9.0', @dummy_child_instance.fetch_version(:inherited_feature), 'Instance should fall back to the parent version'
  end

  def test_subclass_version_overrides_parent_without_changing_it
    ParentClass.version('9.0', :overridden_feature)
    DummyClass.version('10.0', :overridden_feature)
    assert_equal '10.0', DummyClass.fetch_version(:overridden_feature), 'Subclass should use its own version'
    assert_equal '10.0', DummyChildClass.fetch_version(:overridden_feature), 'Grandchild should use its nearest ancestor version'
    assert_equal '9.0', ParentClass.fetch_version(:overridden_feature), 'Parent should keep its own version'
    assert_equal '9.0', FakeClass.fetch_version(:overridden_feature), 'Sibling should keep the parent version'
  end
end
