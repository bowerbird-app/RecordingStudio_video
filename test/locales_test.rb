# frozen_string_literal: true

require "test_helper"
require "yaml"

class LocalesTest < Minitest::Test
  Copy = RecordingStudioVideo::Copy

  EXPECTED = {
    "fields.title.label" => "Title",
    "fields.url.label" => "Video URL",
    "fields.url.hint" => "Paste a link to a supported video, such as YouTube.",
    "fields.description.label" => "Description",
    "probes.boot_mark" => "video-boot-probe"
  }.freeze

  def setup
    @previous_load_path = I18n.load_path.dup
    @previous_backend = I18n.backend
    @previous_locale = I18n.locale
    I18n.backend = I18n::Backend::Simple.new
    I18n.locale = :en
    # Initialize the fresh backend via a public lookup, then load gem English
    # with the public load_translations API (no backend ivar writes).
    begin
      I18n.t("recording_studio.video.fields.title.label", raise: true)
    rescue I18n::MissingTranslationData
      # expected before gem en.yml is loaded onto this fresh backend
    end
    I18n.backend.load_translations(File.join(engine_locales_dir, "en.yml"))
  end

  def teardown
    I18n.backend = @previous_backend
    I18n.locale = @previous_locale
    assert_equal @previous_load_path, I18n.load_path,
                 "locales tests must not mutate I18n.load_path"
  end

  def test_engine_ships_only_english_locale_files
    files = Dir[File.join(engine_locales_dir, "*")].map { |path| File.basename(path) }

    assert_equal ["en.yml"], files.sort
  end

  def test_rails_i18n_load_path_includes_the_gem_english_locale_file
    locale_path = File.expand_path(File.join(engine_locales_dir, "en.yml"))
    existent = RecordingStudioVideo::Engine.paths["config/locales"].existent.map do |path|
      File.expand_path(path)
    end

    assert_includes existent, locale_path
  end

  def test_lib_sources_do_not_append_i18n_load_path
    lib_root = File.expand_path("../lib", __dir__)
    ruby_files = Dir[File.join(lib_root, "**", "*.rb")]

    refute_empty ruby_files, "expected lib/**/*.rb files to scan"

    ruby_files.each do |path|
      source = File.read(path)

      refute_includes source, "i18n.load_path", "#{path} must not touch i18n.load_path"
      refute_includes source, "I18n.load_path", "#{path} must not touch I18n.load_path"
    end
  end

  def test_lib_copy_and_helper_do_not_pass_english_default
    paths = [
      File.expand_path("../lib/recording_studio_video/copy.rb", __dir__),
      File.expand_path("../lib/recording_studio_video/helper.rb", __dir__)
    ]

    paths.each do |path|
      code = File.read(path).lines.grep_v(/^\s*#/).join

      refute_includes code, "default:",
                      "#{path} must not pass English default: to t() or Copy helpers"
    end
  end

  def test_english_video_keys_resolve_from_en_yml_without_default
    I18n.with_locale(:en) do
      EXPECTED.each do |key, english|
        assert_equal english, I18n.t("recording_studio.video.#{key}", raise: true),
                     "expected #{key} to resolve to #{english.inspect}"
        assert_equal english, Copy.t(key),
                     "expected Copy.t(#{key.inspect}) to resolve to #{english.inspect}"
      end
    end
  end

  def test_en_yml_nests_keys_under_recording_studio_video
    tree = locale_tree(File.join(engine_locales_dir, "en.yml"), "en")
           .fetch("recording_studio")
           .fetch("video")

    refute locale_tree(File.join(engine_locales_dir, "en.yml"), "en").key?("recording_studio_video")
    refute tree.key?("errors")

    EXPECTED.each do |key, english|
      parts = key.split(".")
      value = parts.reduce(tree) { |memo, part| memo.fetch(part) }
      assert_equal english, value
    end
  end

  def test_missing_key_raises_like_main_when_raise_on_missing
    I18n.with_locale(:en) do
      assert_raises(I18n::MissingTranslationData) do
        Copy.t("fields.missing_wave2_key", raise: true)
      end
    end
  end

  def test_quoted_yes_no_on_off_keys_resolve_when_present
    keys = collect_yes_no_on_off_keys(
      locale_tree(File.join(engine_locales_dir, "en.yml"), "en")
        .fetch("recording_studio")
        .fetch("video")
    )

    keys.each do |key|
      assert_equal(
        I18n.t("recording_studio.video.#{key}", raise: true),
        Copy.t(key),
        "yes/no/on/off key #{key} must resolve without default:"
      )
    end
  end

  def test_field_labels_resolve_under_french_locale_without_english_default
    I18n.t("recording_studio.video.fields.url.label")
    I18n.backend.store_translations(
      :fr,
      recording_studio: {
        video: {
          fields: {
            url: { label: "URL de la vidéo" }
          }
        }
      }
    )

    previous_locales = I18n.available_locales
    I18n.available_locales = Array(previous_locales) | [:fr]
    I18n.with_locale(:fr) do
      assert_equal "URL de la vidéo", Copy.field_label(:url)
    end
    I18n.with_locale(:en) do
      assert_equal "Video URL", Copy.field_label(:url)
    end
  ensure
    I18n.available_locales = previous_locales if previous_locales
  end

  private

  def engine_locales_dir
    File.expand_path("../config/locales", __dir__)
  end

  def locale_tree(path, locale)
    YAML.safe_load_file(path, aliases: true).fetch(locale)
  end

  def collect_yes_no_on_off_keys(hash, prefix = [])
    hash.flat_map do |key, value|
      path = prefix + [key.to_s]
      if value.is_a?(Hash)
        collect_yes_no_on_off_keys(value, path)
      elsif %w[yes no on off true false null].include?(key.to_s)
        [path.join(".")]
      else
        []
      end
    end
  end
end
