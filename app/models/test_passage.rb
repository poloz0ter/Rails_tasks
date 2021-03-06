# frozen_string_literal: true

class TestPassage < ApplicationRecord
  TEST_PASSED_VALUE = 85
  belongs_to :user
  belongs_to :test
  belongs_to :current_question, class_name: 'Question', optional: true

  before_validation :before_validation_set_first_question

  def completed?
    current_question.nil?
  end

  def accept!(answer_ids)
    self.correct_questions += 1 if correct_answer?(answer_ids)

    save!
  end

  def test_passed?
    percent >= TEST_PASSED_VALUE
  end

  def percent
    percent = (self.correct_questions / test.questions.count.to_f) * 100.0
    percent.round(2)
  end

  def current_question_number
    ids = test.questions.order(:id).pluck(:id)
    ids.index(current_question.id) + 1
  end

  private

  def before_validation_set_first_question
    if current_question.nil?
      self.current_question = test.questions.first if test.present?
    else
      self.current_question = next_question
    end
  end

  def correct_answer?(answer_ids)
    if answer_ids.present?
      correct_answers.ids.sort == answer_ids.map(&:to_i).sort
    else
      false
    end
  end

  def correct_answers
    current_question.answers.correct
  end

  def next_question
    test.questions.order(:id).where('id > ?', current_question.id).first
  end
end
