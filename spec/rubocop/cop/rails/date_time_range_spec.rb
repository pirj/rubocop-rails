# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::DateTimeRange, :config do
  it 'registers an offense when `date.beginning_of_day..date.end_of_day`' do
    expect_offense(<<~RUBY)
      date.beginning_of_day..date.end_of_day
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_day` instead.
    RUBY

    expect_correction(<<~RUBY)
      date.all_day
    RUBY
  end

  it 'registers an offense when `date.beginning_of_week..date.end_of_week`' do
    expect_offense(<<~RUBY)
      date.beginning_of_week..date.end_of_week
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_week` instead.
    RUBY

    expect_correction(<<~RUBY)
      date.all_week
    RUBY
  end

  it 'registers an offense when `date.beginning_of_quarter..date.end_of_quarter`' do
    expect_offense(<<~RUBY)
      date.beginning_of_quarter..date.end_of_quarter
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_quarter` instead.
    RUBY

    expect_correction(<<~RUBY)
      date.all_quarter
    RUBY
  end

  it 'registers an offense when `date.beginning_of_month..date.end_of_month`' do
    expect_offense(<<~RUBY)
      date.beginning_of_month..date.end_of_month
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_month` instead.
    RUBY

    expect_correction(<<~RUBY)
      date.all_month
    RUBY
  end

  it 'registers an offense when `date.beginning_of_year..date.end_of_year`' do
    expect_offense(<<~RUBY)
      date.beginning_of_year..date.end_of_year
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_year` instead.
    RUBY

    expect_correction(<<~RUBY)
      date.all_year
    RUBY
  end

  it 'registers an offense when `date.beginning_of_day..date.end_of_day` and ' \
     'receiver is a method chain' do
    expect_offense(<<~RUBY)
      foo.date.beginning_of_day..foo.date.end_of_day
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `foo.date.all_day` instead.
    RUBY

    expect_correction(<<~RUBY)
      foo.date.all_day
    RUBY
  end

  it 'does not register an offense when receivers do not match' do
    expect_no_offenses(<<~RUBY)
      date1.beginning_of_day..date2.end_of_day
    RUBY
  end

  it 'does not register an offense when methods do not match' do
    expect_no_offenses(<<~RUBY)
      date.beginning_of_day..date.end_of_month
    RUBY
  end

  it 'does not register an offense when `date.beginning_of_day...date.end_of_day`' do
    expect_no_offenses(<<~RUBY)
      date.beginning_of_day...date.end_of_day
    RUBY
  end

  it 'does not register an offense when `date.beginning_of_week(:sunday)..date.end_of_week(:saturday)`' do
    expect_no_offenses(<<~RUBY)
      date.beginning_of_week(:sunday)..date.end_of_week(:saturday)
    RUBY
  end

  it 'does not register an offense when `date.beginning_of_day..date.end_of_day` with any argument' do
    expect_no_offenses(<<~RUBY)
      date.beginning_of_day(arg)..date.end_of_day(arg)
    RUBY
  end

  it 'registers an offense when `date.beginning_of_week(:sunday)..date.end_of_week(:sunday)`' do
    expect_offense(<<~RUBY)
      date.beginning_of_week(:sunday)..date.end_of_week(:sunday)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `date.all_week(:sunday)` instead.
    RUBY

    expect_correction(<<~RUBY)
      date.all_week(:sunday)
    RUBY
  end

  it 'does not register an offense when `date.beginning_of_quarter..date.end_of_quarter` with any argument' do
    expect_no_offenses(<<~RUBY)
      date.beginning_of_quarter(arg)..date.end_of_quarter(arg)
    RUBY
  end

  it 'does not register an offense when `date.beginning_of_month..date.end_of_month` with any argument' do
    expect_no_offenses(<<~RUBY)
      date.beginning_of_month(arg)..date.end_of_month(arg)
    RUBY
  end

  it 'does not register an offense when `date.beginning_of_year..date.end_of_year` with any argument' do
    expect_no_offenses(<<~RUBY)
      date.beginning_of_year(arg)..date.end_of_year(arg)
    RUBY
  end

  context 'Ruby >= 2.6', :ruby26 do
    it 'does not register an offense when `date.beginning_of_day..`' do
      expect_no_offenses(<<~RUBY)
        date.beginning_of_day..
      RUBY
    end
  end

  context 'Ruby >= 2.7', :ruby27 do
    it 'does not register an offense when `..date.end_of_day`' do
      expect_no_offenses(<<~RUBY)
        ..date.end_of_day
      RUBY
    end
  end
end
