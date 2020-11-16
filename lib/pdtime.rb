# frozen_string_literal: true

require 'tzinfo'

class PDTime
  def self.get_offset_for_time_zone(time_zone)
    if time_zone.nil?
      utc_offset = 0
    elsif time_zone.is_a? Integer
      utc_offset = time_zone
    else
      time_zone = ::TZInfo::Timezone.get(time_zone)

      current_period = time_zone.current_period
      utc_offset = current_period.utc_total_offset_rational.numerator
    end

    utc_offset
  end

  def self.get_now_unformatted(time_zone)
    utc_offset = get_offset_for_time_zone(time_zone)

    local = DateTime.now
    local.new_offset(Rational(utc_offset, 24))
  end

  def self.only_now(time_zone)
    now_unformatted = get_now_unformatted(time_zone)

    now_begin = now_unformatted.strftime('%Y-%m-%dT%H:%M:00')
    now_end = now_unformatted.strftime('%Y-%m-%dT%H:%M:01')

    {
      'now_begin' => now_begin,
      'now_end' => now_end
    }
  end

  def self.get_time_offset_from_time(time)
    timezone_string = time[-5..-4].to_i
  end

  def self.is_now?(start, end_time)
    now_source = only_now(get_time_offset_from_time(start))
    inow = time_string_to_integer(now_source['now_begin'])
    istart = time_string_to_integer(start)
    iend = time_string_to_integer(end_time)

    inow >= istart && inow <= iend
  end

  def self.time_string_to_integer(time)
    unless time.nil?
      out = time.tr('-', '')[0..7].to_i
    end

    out
  end

  def self.get_last_day_of_month(month_number)
    local = DateTime.now
    now_unformatted = local.new_offset(Rational(0, 24))
    year = now_unformatted.strftime('%Y').to_i

    Date.civil(year, month_number, -1).strftime('%d').to_i
  end

  def self.get_year_and_month(now_unformatted, month_offset)
    year = now_unformatted.strftime('%Y').to_i
    month = now_unformatted.strftime('%m').to_i + month_offset

    if month > 12
      year += 1
      month = 1
    elsif month < 1
      year -= 1
      month = 12
    end

    {
      'year' => year,
      'month' => month
    }
  end

  def self.get_whole_month(time_zone, month_offset)
    now_unformatted = get_now_unformatted(time_zone)
    year_and_month = get_year_and_month(now_unformatted, month_offset)
    prefix = year_and_month['year'].to_s + '-' + year_and_month['month'].to_s

    last_day = get_last_day_of_month(year_and_month['month']).to_s

    {
      'now_begin' => prefix + '-01T00:00:00',
      'now_end' => prefix + '-' + last_day + 'T23:59:59'
    }
  end

  def self.get_last_month(time_zone)
    get_whole_month(time_zone, -1)
  end

  def self.get_this_month(time_zone)
    get_whole_month(time_zone, 0)
  end

  def self.get_next_month(time_zone)
    get_whole_month(time_zone, 1)
  end

  def self.get_whole_year(time_zone, year_offset)
    now_unformatted = get_now_unformatted(time_zone)
    year = now_unformatted.strftime('%Y').to_i

    requested_year = year + year_offset

    {
      'now_begin' => requested_year.to_s + '-01-01T00:00:00',
      'now_end' => requested_year.to_s + '-12-31T23:59:59'
    }
  end

  def self.get_last_year(time_zone)
    # I imagine this function is only useful a couple of times a year.
    get_whole_year(time_zone, 0)
  end

  def self.get_this_year(time_zone)
    get_whole_year(time_zone, 0)
  end

  def self.get_next_year(time_zone)
    get_whole_year(time_zone, 0)
  end

  def self.get_whole_week(time_zone, week_offset)
    today = get_now_unformatted(time_zone)
    days_since_sunday = 0 - today.wday # Sunday is wday 0
    days_from_today_until_desired_sunday = days_since_sunday + (7 * week_offset)
    desired_week_start = today + days_from_today_until_desired_sunday
    desired_week_end = desired_week_start + 7

    {
      'now_begin' => desired_week_start.strftime('%Y-%m-%d') + 'T23:59:59',
      'now_end' => desired_week_end.strftime('%Y-%m-%d') + 'T00:00:00'
    }
  end
end
