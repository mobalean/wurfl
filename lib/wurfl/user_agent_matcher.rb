module Wurfl; end

=begin
  A class that lists wurfl handsets that match user_agents using the shortest 
  Levenshtein distance, also sometimes called the edit distance, 
  see http://en.wikipedia.org/wiki/Levenshtein_distance

  The implementation of the Levenshtein distance used here is based on the
  algorithm found in the Text gem originally written by Paul Battley
  (pbattley@gmail.com)
   
  The implementation given here makes heavy use of optimizations based on 
  the estimation of the lower bound that can be achieved.  Depending on the 
  length of the user agent this brought an over all increase by a factor of
  about 40, although it renders the code slightly unreadable.  In general the
  longer the user agent string and the greater the result distance, the longer
  the computation takes.  
  
  Author:  Kai W. Zimmermann (kwz@kai-zimmermann.de)
=end
class Wurfl::UserAgentMatcher
  # Constructor
  # Parameters:
  # handsets: A hashtable of wurfl handsets indexed by wurfl_id.
  def initialize(handsets)
    @handsets = handsets
    @longest_user_agent_length = 0
    @handsets.values.each do |hand| 
      if(@longest_user_agent_length<hand.user_agent.length) then
        @longest_user_agent_length = hand.user_agent.length
      end
    end
    @d=(0..@longest_user_agent_length).to_a
  end

  # A method to retrieve a list of the uamatcher's handsets that match
  # the passed user_agent closest using the Levenshtein distance.
  # Parameters:
  # user_agent: is a user_agent string to be matched
  # Returns:
  # An Array of all WurflHandsets that match the user_agent closest with the same distance
  # The Levenshtein distance for these matches
  def match_handsets(user_agent)
    rez = Array::new
    if (user_agent.length<@longest_user_agent_length) then
      shortest_distance = @longest_user_agent_length 
    else
      shortest_distance = user_agent.length
    end
    if $KCODE =~ /^U/i
      unpack_rule = 'U*'
    else
      unpack_rule = 'C*'
    end
    s = user_agent.unpack(unpack_rule)
    @handsets.values.each do |hand|    
      distance = levenshtein_distance(user_agent, hand.user_agent, shortest_distance, unpack_rule, s)
      if(shortest_distance>distance)
        # found a shorter distance match, flush old results 
        rez = Array::new   
      end
      if(shortest_distance>=distance) then
        # always add the first handset matched and each that has the same distance as the shortest distance so far 
        rez << hand
        shortest_distance=distance
      end
      if shortest_distance==0 then return rez, 0 end
    end
    return rez, shortest_distance 
  end
  
  # A method to estimate and compute the Levenshtein distance (LD) based on the implementation from the Text gem.
  # The implementation given here applies known upper and lower bounds as found at: http://en.wikipedia.org/wiki/Levenshtein_distance 
  # LD is always at least the difference of the sizes of the two strings.
  #  -> We can safely discard the handset if the least distance is longer than the current shortest distance
  # LD is zero if and only if the strings are identical.
  #  -> We can optimize the test for equality and stop searching after an exact match
  # Parameters:
  # str1: is the user-agent to look up
  # str2: is the user-agent to compare against
  # min: is the minimum distance found so far
  # unpack_rule:  the rule by which to unpack the string into an array
  # s: the unpacked version of the user-agent string we look up
  # Returns:
  # It returns the least bound estimation if the least bound is already greater than the current minimum distance
  # Otherwise it will compute the Levenshtein distance of str1 and str2
  # It optimizes the check for equality
  def levenshtein_distance ( str1, str2, min, unpack_rule, s )
    diff=(str1.length-str2.length).abs
    if(diff==0) then 
      if(str1==str2)then
        return 0
      end
    elsif (diff>min)
      return diff
    end
    t = str2.unpack(unpack_rule)
    return distance(s, t, min)
  end

  # Compute the Levenshtein distance or stop if the minimum found so far will be exceeded.
  # Optimizations:  Avoid GC, where possible reuse array
  # The distance computation in the outer loop is monotonously decreasing thus
  # we can safely stop if the estimated possible minimum exceeds the current minimum
  # Parameters:
  # s: is the first string, already unpacked
  # t: is the second string, already unpacked
  # min: is the minimum distance found so far
  # Returns:
  # The routine returns the computed distance or the minimum found so far if the distance 
  # computed so far exceeds the minimum
  def distance(s, t, min)
    n = s.length
    m = t.length
    return m if (0 == n)
    return n if (0 == m)

    d=@d
    (0...m).each do |j|
      d[j]=j
    end
    x = 0
    (0...n).each do |i|
      e = i+1
      (0...m).each do |j|
        cost = (s[i] == t[j]) ? 0 : 1
        x = d[j+1] + 1 # insertion
        y = e+1
        x = y if (y<x) # deletion
        z = d[j] + cost
        x = z if (z<x) # substitution
        d[j] = e
        e = x
      end
      d[m] = x
      # estimate the minimum LD that still can be achieved, this will be increasing monotonously
      # stop once we exceed the current minimum
      if x-n+i+1 > min then return x-n+i+1 end
    end
    return x
  end
end
