require 'test_helper'

class TestJekyllPandocMultipleFormats < MiniTest::Test
  context 'imposition' do
    setup do
      @imposition = JekyllPandocMultipleFormats::Imposition.new(TEST_PDF)
    end

    should 'have a new file name' do
      assert_equal TEST_IMPOSED_PDF, @imposition.output_file
    end

    should 'write a new filename' do
      assert @imposition.write
      assert File.exists?(TEST_IMPOSED_PDF)
      assert FileUtils.rm(TEST_IMPOSED_PDF)
    end

    should 'have number of pages' do
      assert_equal 23, @imposition.pages
    end

    should 'have a sheet size' do
      assert_equal 'a4paper', @imposition.sheetsize
    end

    should 'have a page size' do
      assert_equal 'a5paper', @imposition.papersize
    end

    should 'have rounded pages' do
      assert_equal 24, @imposition.rounded_pages
    end

    should 'have blank pages' do
      assert_equal 1, @imposition.blank_pages
    end

    should 'have a signature' do
      assert_equal 24, @imposition.signature
    end

    should 'have ordered pages' do
      assert_equal ["{}", 1, 2, 23, 22, 3, 4, 21, 20, 5, 6, 19, 18, 7, 8, 17, 16, 9, 10, 15, 14, 11, 12, 13], @imposition.to_nup
    end
  end

  context 'signed imposition' do
    setup do
      @imposition = JekyllPandocMultipleFormats::Imposition.new(TEST_PDF, 'a5paper', 'a4paper', 12)
    end

    should 'have a sheet size' do
      assert_equal 'a4paper', @imposition.sheetsize
    end

    should 'have a page size' do
      assert_equal 'a5paper', @imposition.papersize
    end

    should 'have a signature' do
      assert_equal 12, @imposition.signature
    end

    should 'have ordered pages' do
      assert_equal [12, 1, 2, 11, 10, 3, 4, 9, 8, 5, 6, 7, "{}", 13, 14, 23, 22, 15, 16, 21, 20, 17, 18, 19], @imposition.to_nup
    end
  end

  context '2x1 imposition' do
    setup do
      @impositions = []

      [
        { p: 'a7paper', s: 'a6paper' },
        { p: 'a6paper', s: 'a5paper' },
        { p: 'a5paper', s: 'a4paper' },
        { p: 'a4paper', s: 'a3paper' },
        { p: 'a3paper', s: 'a2paper' },
        { p: 'a2paper', s: 'a1paper' },
        { p: 'a1paper', s: 'a0paper' }
      ].each do |i|
        @impositions << JekyllPandocMultipleFormats::Imposition.new(TEST_PDF, i[:p], i[:s])
      end
    end

    should 'have ordered pages' do
      @impositions.each do |i|
        assert_equal ["{}", 1, 2, 23, 22, 3, 4, 21, 20, 5, 6, 19, 18, 7, 8, 17, 16, 9, 10, 15, 14, 11, 12, 13], i.to_nup
      end
    end
  end

  context '4x1 imposition' do
    setup do
      @impositions = []

      [
        { p: 'a7paper', s: 'a5paper' },
        { p: 'a6paper', s: 'a4paper' },
        { p: 'a5paper', s: 'a3paper' },
        { p: 'a4paper', s: 'a2paper' },
        { p: 'a3paper', s: 'a1paper' },
        { p: 'a2paper', s: 'a0paper' }
      ].each do |i|
        @impositions << JekyllPandocMultipleFormats::Imposition.new(TEST_PDF, i[:p], i[:s])
      end
    end

    should 'have ordered pages' do
      @impositions.each do |i|
        assert_equal ["{}", 1, "{}", 1,
           2, 23,  2, 23,
          22,  3, 22,  3,
           4, 21,  4, 21,
          20,  5, 20,  5,
           6, 19,  6, 19,
          18,  7, 18,  7,
           8, 17,  8, 17,
          16,  9, 16,  9,
          10, 15, 10, 15,
          14, 11, 14, 11,
          12, 13, 12, 13],
          i.to_nup
      end
    end
  end

  context '8x1 imposition' do
    setup do
      @impositions = []

      [
        { p: 'a7paper', s: 'a4paper' },
        { p: 'a6paper', s: 'a3paper' },
        { p: 'a5paper', s: 'a2paper' },
        { p: 'a4paper', s: 'a1paper' },
        { p: 'a3paper', s: 'a0paper' }
      ].each do |i|
        @impositions << JekyllPandocMultipleFormats::Imposition.new(TEST_PDF, i[:p], i[:s])
      end
    end

    should 'have ordered pages' do
      @impositions.each do |i|
        assert_equal [
          "{}", 1, "{}", 1, "{}", 1, "{}", 1,
           2, 23,  2, 23,  2, 23,  2, 23,
          22,  3, 22,  3, 22,  3, 22,  3,
           4, 21,  4, 21,  4, 21,  4, 21,
          20,  5, 20,  5, 20,  5, 20,  5,
           6, 19,  6, 19,  6, 19,  6, 19,
          18,  7, 18,  7, 18,  7, 18,  7,
           8, 17,  8, 17,  8, 17,  8, 17,
          16,  9, 16,  9, 16,  9, 16,  9,
          10, 15, 10, 15, 10, 15, 10, 15,
          14, 11, 14, 11, 14, 11, 14, 11,
          12, 13, 12, 13, 12, 13, 12, 13],
          i.to_nup
      end
    end
  end

  context '16x1 imposition' do
    setup do
      @impositions = []

      [
        { p: 'a7paper', s: 'a3paper' },
        { p: 'a6paper', s: 'a2paper' },
        { p: 'a5paper', s: 'a1paper' },
        { p: 'a4paper', s: 'a0paper' }
      ].each do |i|
        @impositions << JekyllPandocMultipleFormats::Imposition.new(TEST_PDF, i[:p], i[:s])
      end
    end

    should 'have ordered pages' do
      @impositions.each do |i|
        assert_equal [
          "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1,
           2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,
          22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3,
           4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,
          20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5,
           6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,
          18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7,
           8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,
          16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9,
          10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15,
          14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11,
          12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13],
          i.to_nup
        end
    end
  end

  context '32x1 imposition' do
    setup do
      @impositions = []

      [
        { p: 'a7paper', s: 'a2paper' },
        { p: 'a6paper', s: 'a1paper' },
        { p: 'a5paper', s: 'a0paper' }
      ].each do |i|
        @impositions << JekyllPandocMultipleFormats::Imposition.new(TEST_PDF, i[:p], i[:s])
      end
    end

    should 'have ordered pages' do
      @impositions.each do |i|
        assert_equal [
           "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1, "{}", 1,
           2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,  2, 23,
          22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3, 22,  3,
           4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,  4, 21,
          20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5, 20,  5,
           6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,  6, 19,
          18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7, 18,  7,
           8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,  8, 17,
          16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9, 16,  9,
          10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15, 10, 15,
          14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11, 14, 11,
          12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13, 12, 13],
          i.to_nup
      end
    end
  end

  context 'binder' do
    setup do
      @binder = JekyllPandocMultipleFormats::Binder.new(TEST_PDF)
    end

    should 'write a new filename' do
      assert @binder.write
      assert File.exists?(TEST_BINDER_PDF)
      assert FileUtils.rm(TEST_BINDER_PDF)
    end

    should 'have number of pages' do
      assert_equal 23, @binder.pages
    end

    should 'have a sheet size' do
      assert_equal 'a4paper', @binder.sheetsize
    end

    should 'have a page size' do
      assert_equal 'a5paper', @binder.papersize
    end
  end

  context '2x1 binder' do
    setup do
      @binder = []

      [
        { p: 'a7paper', s: 'a6paper' },
        { p: 'a6paper', s: 'a5paper' },
        { p: 'a5paper', s: 'a4paper' },
        { p: 'a4paper', s: 'a3paper' },
        { p: 'a3paper', s: 'a2paper' },
        { p: 'a2paper', s: 'a1paper' },
        { p: 'a1paper', s: 'a0paper' }
      ].each do |i|
        @binder << JekyllPandocMultipleFormats::Binder.new(TEST_PDF, i[:p], i[:s])
      end
    end

    should 'have ordered pages' do
      @binder.each do |i|
        assert_equal [
           1,  1,
           2,  2,
           3,  3,
           4,  4,
           5,  5,
           6,  6,
           7,  7,
           8,  8,
           9,  9,
          10, 10,
          11, 11,
          12, 12,
          13, 13,
          14, 14,
          15, 15,
          16, 16,
          17, 17,
          18, 18,
          19, 19,
          20, 20,
          21, 21,
          22, 22,
          23, 23 ], i.to_nup
      end
    end
  end

  context '4x1 binder' do
    setup do
      @binder = []

      [
        { p: 'a7paper', s: 'a5paper' },
        { p: 'a6paper', s: 'a4paper' },
        { p: 'a5paper', s: 'a3paper' },
        { p: 'a4paper', s: 'a2paper' },
        { p: 'a3paper', s: 'a1paper' },
        { p: 'a2paper', s: 'a0paper' }
      ].each do |i|
        @binder << JekyllPandocMultipleFormats::Binder.new(TEST_PDF, i[:p], i[:s])
      end
    end

    should 'have ordered pages' do
      @binder.each do |i|
        assert_equal [
           1,  1,  1,  1,
           2,  2,  2,  2,
           3,  3,  3,  3,
           4,  4,  4,  4,
           5,  5,  5,  5,
           6,  6,  6,  6,
           7,  7,  7,  7,
           8,  8,  8,  8,
           9,  9,  9,  9,
          10, 10, 10, 10,
          11, 11, 11, 11,
          12, 12, 12, 12,
          13, 13, 13, 13,
          14, 14, 14, 14,
          15, 15, 15, 15,
          16, 16, 16, 16,
          17, 17, 17, 17,
          18, 18, 18, 18,
          19, 19, 19, 19,
          20, 20, 20, 20,
          21, 21, 21, 21,
          22, 22, 22, 22,
          23, 23, 23, 23],
          i.to_nup
      end
    end
  end

  context '8x1 binder' do
    setup do
      @binder = []

      [
        { p: 'a7paper', s: 'a4paper' },
        { p: 'a6paper', s: 'a3paper' },
        { p: 'a5paper', s: 'a2paper' },
        { p: 'a4paper', s: 'a1paper' },
        { p: 'a3paper', s: 'a0paper' }
      ].each do |i|
        @binder << JekyllPandocMultipleFormats::Binder.new(TEST_PDF, i[:p], i[:s])
      end
    end

    should 'have ordered pages' do
      @binder.each do |i|
        assert_equal [
           1,  1,  1,  1,  1,  1,  1,  1,
           2,  2,  2,  2,  2,  2,  2,  2,
           3,  3,  3,  3,  3,  3,  3,  3,
           4,  4,  4,  4,  4,  4,  4,  4,
           5,  5,  5,  5,  5,  5,  5,  5,
           6,  6,  6,  6,  6,  6,  6,  6,
           7,  7,  7,  7,  7,  7,  7,  7,
           8,  8,  8,  8,  8,  8,  8,  8,
           9,  9,  9,  9,  9,  9,  9,  9,
          10, 10, 10, 10, 10, 10, 10, 10,
          11, 11, 11, 11, 11, 11, 11, 11,
          12, 12, 12, 12, 12, 12, 12, 12,
          13, 13, 13, 13, 13, 13, 13, 13,
          14, 14, 14, 14, 14, 14, 14, 14,
          15, 15, 15, 15, 15, 15, 15, 15,
          16, 16, 16, 16, 16, 16, 16, 16,
          17, 17, 17, 17, 17, 17, 17, 17,
          18, 18, 18, 18, 18, 18, 18, 18,
          19, 19, 19, 19, 19, 19, 19, 19,
          20, 20, 20, 20, 20, 20, 20, 20,
          21, 21, 21, 21, 21, 21, 21, 21,
          22, 22, 22, 22, 22, 22, 22, 22,
          23, 23, 23, 23, 23, 23, 23, 23],
          i.to_nup
      end
    end
  end

  context '16x1 binder' do
    setup do
      @binder = []

      [
        { p: 'a7paper', s: 'a3paper' },
        { p: 'a6paper', s: 'a2paper' },
        { p: 'a5paper', s: 'a1paper' },
        { p: 'a4paper', s: 'a0paper' }
      ].each do |i|
        @binder << JekyllPandocMultipleFormats::Binder.new(TEST_PDF, i[:p], i[:s])
      end
    end

    should 'have ordered pages' do
      @binder.each do |i|
        assert_equal [
           1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
           2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,
           3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,
           4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
           5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,
           6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,
           7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,
           8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,
           9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,
          10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
          11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
          12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
          13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
          14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
          15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
          16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
          17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
          18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
          19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19,
          20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
          21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
          22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
          23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23],
          i.to_nup
        end
    end
  end

  context '32x1 binder' do
    setup do
      @binder = []

      [
        { p: 'a7paper', s: 'a2paper' },
        { p: 'a6paper', s: 'a1paper' },
        { p: 'a5paper', s: 'a0paper' }
      ].each do |i|
        @binder << JekyllPandocMultipleFormats::Binder.new(TEST_PDF, i[:p], i[:s])
      end
    end

    should 'have ordered pages' do
      @binder.each do |i|
        assert_equal [
           1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
           2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,
           3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,
           4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
           5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,
           6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,
           7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,
           8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,
           9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,
          10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
          11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
          12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
          13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
          14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
          15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
          16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
          17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
          18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18,
          19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19,
          20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
          21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
          22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
          23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23],
          i.to_nup
      end
    end
  end
end
