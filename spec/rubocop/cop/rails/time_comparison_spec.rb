# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::TimeComparison, :config do
  it do
    expect_offense(<<~RUBY)
      time < Time.current
      ^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time > Time.current
      ^^^^^^^^^^^^^^^^^^^ Use `time.future?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.future?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current > time
      ^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current < time
      ^^^^^^^^^^^^^^^^^^^ Use `time.future?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.future?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time < ::Time.current
      ^^^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time < Time.zone.now
      ^^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time.before?(Time.current)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time.after?(Time.current)
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.future?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.future?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current.before?(time)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.future?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.future?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current.after?(time)
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.zone.now.before?(time)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.future?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.future?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      time&.before?(Time.current)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time&.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time&.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      reminder&.remind_at.before?(Time.current)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `reminder&.remind_at.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      reminder&.remind_at.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      Time.current&.after?(time)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `time.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      time.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      reminder.remind_at < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `reminder.remind_at.past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      reminder.remind_at.past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      times[0] < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^ Use `times[0].past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      times[0].past?
    RUBY
  end

  it do
    expect_offense(<<~RUBY)
      (starts_at || ends_at) < Time.current
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `(starts_at || ends_at).past?` instead.
    RUBY

    expect_correction(<<~RUBY)
      (starts_at || ends_at).past?
    RUBY
  end

  it 'does not register an offense when a day would have to be moved across the comparison, ' \
     'as a calendar day is not always 24 hours long (DST)' do
    expect_no_offenses(<<~RUBY)
      time + 1.day < Time.current
      (time + 1.day) < Time.current
      time + 1.week < Time.current
      (time + 1.day).past?
    RUBY
  end

  it 'does not register an offense when a month would have to be moved across the comparison, ' \
     'as end-of-month clamping makes it irreversible: Jan 31 + 1 month is Feb 28, and Feb 28 - 1 month is Jan 28' do
    expect_no_offenses(<<~RUBY)
      time + 1.month < Time.current
      time + 1.year < Time.current
    RUBY
  end

  it 'does not register an offense for an operand of an unknown unit, ' \
     'as it may be a calendar duration, or an Integer number of seconds that has no `ago`' do
    expect_no_offenses(<<~RUBY)
      time + backoff < Time.current
    RUBY
  end

  it 'does not register an offense for elapsed time compared with a calendar duration, ' \
     'as subtracting times gives absolute seconds, while `1.day.ago` is a calendar day back' do
    expect_no_offenses(<<~RUBY)
      Time.current - time > 1.day
    RUBY
  end

  it 'does not register an offense for a safe navigation operand, ' \
     'as the correction would return `nil` where the comparison raises `NoMethodError`' do
    expect_no_offenses(<<~RUBY)
      reminder&.remind_at < Time.current
      Time.current.after?(reminder&.remind_at)
    RUBY
  end

  it 'does not register an offense for a non-strict comparison, as `past?` and `future?` exclude the current time' do
    expect_no_offenses(<<~RUBY)
      time <= Time.current
      time >= Time.current
    RUBY
  end

  it 'does not register an offense for an equality check, as it has no `past?` or `future?` counterpart' do
    expect_no_offenses(<<~RUBY)
      time == Time.current
    RUBY
  end

  it 'does not register an offense for a comparison with `Date.current`, ' \
     'as it is the beginning of the day: a time earlier this morning is after it, but still in the past' do
    expect_no_offenses(<<~RUBY)
      time > Date.current
      time > Time.zone.today
    RUBY
  end

  it 'does not register an offense for `Time.now`, which `Rails/TimeZone` replaces first' do
    expect_no_offenses(<<~RUBY)
      time < Time.now
    RUBY
  end

  it 'does not register an offense for a value derived from the current time, as it is not the current time' do
    expect_no_offenses(<<~RUBY)
      year < Time.current.year
      time < Time.current.beginning_of_day
    RUBY
  end
end
