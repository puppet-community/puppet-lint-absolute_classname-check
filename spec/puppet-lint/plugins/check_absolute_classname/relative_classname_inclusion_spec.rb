require 'spec_helper'

describe 'relative_classname_inclusion' do
  let(:msg) { 'class included by absolute name (::$class)' }

  context 'with fix disabled' do
    context 'when absolute names are used' do
      let(:code) do
        <<-EOS
        include ::foobar
        include('::foobar')
        include(foobar(baz))
        include(foobar('baz'))

        include ::foo, ::bar
        include('::foo', '::bar')

        class { '::foobar': }

        class foobar {
        }

        contain ::foobar
        contain('::foobar')
        contain(foobar(baz))
        contain(foobar('baz'))

        require ::foobar
        require('::foobar')
        require(foobar(baz))
        require(foobar('baz'))

        class foobar inherits ::baz {
        }
        EOS
      end

      it 'detects 12 problems' do
        expect(problems).to have(12).problems
      end

      it 'creates warnings' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(17)
        expect(problems).to contain_warning(msg).on_line(2).in_column(17)
        expect(problems).to contain_warning(msg).on_line(6).in_column(17)
        expect(problems).to contain_warning(msg).on_line(6).in_column(24)
        expect(problems).to contain_warning(msg).on_line(7).in_column(17)
        expect(problems).to contain_warning(msg).on_line(7).in_column(26)
        expect(problems).to contain_warning(msg).on_line(9).in_column(17)
        expect(problems).to contain_warning(msg).on_line(14).in_column(17)
        expect(problems).to contain_warning(msg).on_line(15).in_column(17)
        expect(problems).to contain_warning(msg).on_line(19).in_column(17)
        expect(problems).to contain_warning(msg).on_line(20).in_column(17)
        expect(problems).to contain_warning(msg).on_line(24).in_column(31)
      end
    end

    context 'when relative names are used' do
      let(:code) do
        <<-EOS
        include foobar
        include(foobar)
        class { 'foobar': }
        contain foobar
        contain(foobar)
        require foobar
        require(foobar)
        class foobar inherits baz {
        }
        EOS
      end

      it 'does not detect a problem' do
        expect(problems).to have(0).problems
      end
    end

    context 'when the require metadata parameter is used' do
      let(:code) do
        <<-EOS
        file { '/path':
          ensure  => present,
          require => Shellvar['http_proxy'],
        }
        EOS
      end

      it 'detects no problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'when require is a hash key' do
      let(:code) do
        <<-EOS
        $defaults = {
          require => Exec['apt_update'],
        }
        $defaults = {
          'require' => Exec['apt_update'],
        }
        EOS
      end

      it 'detects no problems' do
        expect(problems).to have(0).problems
      end
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    context 'when absolute names are used' do
      let(:code) do
        <<-EOS
        include ::foobar
        include('::foobar')
        include(foobar(baz))
        include(foobar('baz'))

        include ::foo, ::bar
        include('::foo', '::bar')

        class { '::foobar': }

        class foobar {
        }

        contain ::foobar
        contain('::foobar')
        contain(foobar(baz))
        contain(foobar('baz'))

        require ::foobar
        require('::foobar')
        require(foobar(baz))
        require(foobar('baz'))

        class foobar inherits ::baz {
        }
        EOS
      end

      it 'detects 12 problems' do
        expect(problems).to have(12).problems
      end

      it 'fixes the problems' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(17)
        expect(problems).to contain_fixed(msg).on_line(2).in_column(17)
        expect(problems).to contain_fixed(msg).on_line(6).in_column(17)
        expect(problems).to contain_fixed(msg).on_line(6).in_column(24)
        expect(problems).to contain_fixed(msg).on_line(7).in_column(17)
        expect(problems).to contain_fixed(msg).on_line(7).in_column(26)
        expect(problems).to contain_fixed(msg).on_line(9).in_column(17)
        expect(problems).to contain_fixed(msg).on_line(14).in_column(17)
        expect(problems).to contain_fixed(msg).on_line(15).in_column(17)
        expect(problems).to contain_fixed(msg).on_line(19).in_column(17)
        expect(problems).to contain_fixed(msg).on_line(20).in_column(17)
        expect(problems).to contain_fixed(msg).on_line(24).in_column(31)
      end

      it 'shoulds remove colons' do
        expect(manifest).to eq(
          <<-EOS,
        include foobar
        include('foobar')
        include(foobar(baz))
        include(foobar('baz'))

        include foo, bar
        include('foo', 'bar')

        class { 'foobar': }

        class foobar {
        }

        contain foobar
        contain('foobar')
        contain(foobar(baz))
        contain(foobar('baz'))

        require foobar
        require('foobar')
        require(foobar(baz))
        require(foobar('baz'))

        class foobar inherits baz {
        }
        EOS
        )
      end
    end

    context 'when relative names are used' do
      let(:code) do
        <<-EOS
        include foobar
        include(foobar)
        class { 'foobar': }
        contain foobar
        contain(foobar)
        require foobar
        require(foobar)
        class foobar inherits baz {
        }
        EOS
      end

      it 'does not detect any problems' do
        expect(problems).to have(0).problems
      end
    end
  end

  describe '(#12) behavior of lookup("foo", {merge => unique}).include' do
    let(:msg) { '(#12) class included with lookup("foo", {merge => unique}).include' }

    let(:code) do
      <<-EOS
      lookup(foo, {merge => unique}).include
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
