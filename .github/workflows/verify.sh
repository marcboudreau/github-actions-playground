#!/bin/bash
set -eu${DEBUG+x}o pipefail

for f in *.yml ; do
  if [[ "$f" = 'wc-print-contexts.yml' ]] ; then
    continue
  fi

  event_name="$(head -3 "$f" | tail -1 | sed -e 's/:$//' -e 's/ //g')"
  event_type=""

  if head -4 "$f" | tail -1 | grep -q 'types:' ; then
    event_type=$(head -5 "$f" | tail -1 | sed -e 's/[ -]//g')
  fi

  # Make sure the filename matches the event_name and event_type (if applicable)
  expected_filename="$event_name"
  if [[ -n "$event_type" ]] ; then
    expected_filename="${expected_filename}_$event_type"
  fi
  expected_filename="${expected_filename}.yml"

  test "$f" = "$expected_filename" || echo "$f filename does not match the event name $event_name"

  concurrency=$(tail -2 "$f" | head -1 | sed -e 's/concurrency://' -e 's/-${{ github.ref }}//' -e 's/ //g' )
  test "$concurrency" = "${event_name}${event_type:+_}${event_type}" || echo "$f concurrency group [$concurrency] doesn't match. event_name: [$event_name], event_type: [$event_type]"
  
done