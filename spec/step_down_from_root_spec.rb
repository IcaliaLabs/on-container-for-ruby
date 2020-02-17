# frozen_string_literal: true

require 'on_container/step_down_from_root'

RSpec.describe OnContainer::StepDownFromRoot do
  let(:root_user) do
    instance_double "struct Etc::Passwd",
                    name: 'root',
                    passwd: 'x',
                    uid: 0,
                    gid: 0,
                    gecos: 'root',
                    dir: '/root',
                    shell: '/bin/bash'
  end

  let(:developer_user) do
    instance_double "struct Etc::Passwd",
                    name: 'developer',
                    passwd: 'x',
                    uid: 1000,
                    gid: 1000,
                    gecos: 'Developer User,,,',
                    dir: '/usr/src',
                    shell: '/bin/bash'
  end

  let(:example_current_user) { root_user }
  let(:example_target_user) { developer_user }
  let(:example_developer_uid) { '1000' }

  before do
    allow(ENV).to receive(:fetch).with('DEVELOPER_UID', '') { example_developer_uid }
    allow(Etc).to receive(:getpwuid) { example_current_user }
    allow(Etc).to receive(:getpwuid).with(example_target_user.uid) { example_target_user }
    allow(Kernel).to receive(:exec).with('su-exec', example_target_user.name, any_args)
  end

  describe '#perform' do
    it 'changes to the target user' do
      subject.perform
      expect(Kernel).to have_received(:exec).with 'su-exec', example_target_user.name, any_args
    end

    context 'without a developer uid' do
      let(:example_developer_uid) { '' }
      
      example 'does not change the current user' do
        subject.perform
        expect(Kernel).not_to have_received(:exec)
      end
    end

    context 'when not as root' do
      let(:example_current_user) { developer_user }
      
      example 'does not change the current user' do
        subject.perform
        expect(Kernel).not_to have_received(:exec)
      end
    end
  end
end
