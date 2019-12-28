class Cl
  class Parser < OptionParser
    class Format < Struct.new(:opt)
      NAME = /^(--(?:\[no-\])?)([^= ]+)/

      def strs
        strs = opt.strs + aliases
        strs.map { |str| long?(str) ? long(str) : short(str) }.flatten
      end

      def long(str)
        strs = [unnegate(str)]
        strs = strs.map { |str| negated(str) }.flatten if flag?
        strs = collect(strs, :dashed)
        strs = collect(strs, :underscored)
        strs = collect(strs, :valued) if flag? && Cl.flag_values
        strs.uniq
      end

      def short(str)
        str = "#{str} #{opt.name.upcase}" unless opt.flag? || str.include?(' ')
        str
      end

      def unnegate(str)
        str.sub('--[no-]', '--')
      end

      def aliases
        opt.aliases.map { |name| "--#{name} #{ name.upcase unless opt.flag?}".strip }
      end

      def collect(strs, mod)
        strs = strs + strs.map { |str| send(mod, str) }
        strs.flatten.uniq
      end

      def negated(str)
        str.dup.insert(2, '[no-]')
      end

      def dashed(str)
        str =~ NAME && str.sub("#{$1}#{$2}", "#{$1}#{$2.tr('_', '-')}") || str
      end

      def underscored(str)
        str =~ NAME && str.sub("#{$1}#{$2}", "#{$1}#{$2.tr('-', '_')}") || str
      end

      def valued(str)
        "#{str} [true|false|yes|no]"
      end

      def long?(str)
        str.start_with?('--')
      end

      def flag?
        opt.flag? && !opt.help?
      end
    end
  end
end
