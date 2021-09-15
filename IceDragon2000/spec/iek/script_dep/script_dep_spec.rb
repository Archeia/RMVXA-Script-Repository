require_relative '../spec_helper'
require 'iek/script_dep/script_dep'

describe ScriptDep do
  let(:registry) { ScriptDep.new }

  context '#register' do
    it 'should register a new item' do
      registry.r('iek/awesomeness', '0.1.0')
    end

    it 'should fail to register the same item' do
      registry.r('iek/awesomeness', '0.1.0')
      expect { registry.r('iek/awesomeness', '0.1.0') }.to raise_error(ScriptDep::RegisterError)
    end

    it 'should fail to register the same item with a different version' do
      registry.r('iek/awesomeness', '0.1.0')
      expect { registry.r('iek/awesomeness', '0.2.0') }.to raise_error(ScriptDep::RegisterError)
    end
  end

  context '#depend!' do
    context '== version' do
      it 'should check same versions' do
        registry.r('iek/awesomeness', '0.1.0')
        registry.depend!('iek/awesomeness', '== 0.1.0')
      end
    end

    context '~> version' do
      it 'should check minor versions' do
        registry.r('iek/awesomeness', '0.2.0')
        registry.depend!('iek/awesomeness', '~> 0.1')
      end

      it 'should fail major version differences' do
        registry.r('iek/awesomeness', '1.2.0')
        expect { registry.depend!('iek/awesomeness', '~> 0.1') }.to raise_error(ScriptDep::InvalidDependency)
      end
    end

    context '> version' do
      it 'should check greater than versions' do
        registry.r('iek/awesomeness', '0.3.0')
        registry.depend!('iek/awesomeness', '> 0.1')
      end

      it 'should fail wrong versions' do
        registry.r('iek/awesomeness', '1.2.0')
        expect { registry.depend!('iek/awesomeness', '> 2.1') }.to raise_error(ScriptDep::InvalidDependency)
      end
    end

    context '< version' do
      it 'should check less than versions' do
        registry.r('iek/awesomeness', '0.5.0')
        registry.depend!('iek/awesomeness', '< 0.7')
      end

      it 'should fail wrong versions' do
        registry.r('iek/awesomeness', '1.5.0')
        expect { registry.depend!('iek/awesomeness', '< 0.5') }.to raise_error(ScriptDep::InvalidDependency)
      end
    end

    context '>= version' do
      it 'should check greater than or equal versions' do
        registry.r('iek/awesomeness', '0.3.0')
        registry.depend!('iek/awesomeness', '>= 0.3.0')
      end

      it 'should fail wrong versions' do
        registry.r('iek/awesomeness', '1.2.5')
        expect { registry.depend!('iek/awesomeness', '>= 1.2.6') }.to raise_error(ScriptDep::InvalidDependency)
      end
    end

    context '<= version' do
      it 'should check less than or equal versions' do
        registry.r('iek/awesomeness', '0.4.0')
        registry.depend!('iek/awesomeness', '<= 0.4.9')
      end

      it 'should fail wrong versions' do
        registry.r('iek/awesomeness', '0.4.0')
        expect { registry.depend!('iek/awesomeness', '<= 0.3.8') }.to raise_error(ScriptDep::InvalidDependency)
      end
    end
  end
end
