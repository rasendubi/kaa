/*
 * Copyright 2014-2016 CyberVision, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.kaaproject.kaa.server.transport;

import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

/**
 * Converts a range expression ("1-3, 2-7, 15") into a sequence of numbers from that range
 */
public final class RangeExpressionParser {

    private static final String RANGE_DELIMITER_REGEX = ",";
    private static final String BOUNDS_DELIMITER_REGEX = "-";

    public List<Integer> getNumbersFromRanges(String expression) {
        if (expression == null) {
            throw new IllegalArgumentException("Expression can not be null");
        }

        // Using a TreeSet to retrieve a sorted list of numbers in result
        TreeSet result = new TreeSet<Integer>();
        for (Range range : parseRanges(expression)) {
            for (int i = range.from; i <= range.to; i++) {
                result.add(i);
            }
        }
        return new ArrayList<>(result);
    }

    private List<Range> parseRanges(String expression) {
        List<Range> ranges = new ArrayList<>();
        for (String range : expression.split(RANGE_DELIMITER_REGEX)) {
            ranges.add(parseRange(range));
        }
        return ranges;
    }

    private Range parseRange(String range) {
        String[] bounds = range.split(BOUNDS_DELIMITER_REGEX);
        if (bounds.length != 1 && bounds.length != 2) {
            throw new IllegalArgumentException("Wrong number of bounds for range");
        }

        int from = Integer.parseInt(bounds[0].trim());
        int to = (bounds.length == 2) ? Integer.parseInt(bounds[1].trim()) : from;
        return new Range(from, to);
    }

    private static class Range {
        public int from;
        public int to;

        private Range(int from, int to) {
            this.from = from;
            this.to = to;
        }
    }
}
