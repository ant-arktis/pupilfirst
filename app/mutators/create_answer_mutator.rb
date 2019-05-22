class CreateAnswerMutator < ApplicationMutator
  include ActiveSupport::Concern

  attr_accessor :description
  attr_accessor :question_id

  validates :description, length: { minimum: 1, message: 'InvalidLengthValue' }, allow_nil: false
  validates :question_id, presence: { message: 'BlankCommentableId' }

  def create_answer
    answer = Answer.create!(
      user: current_user,
      question: question
    )
    answer.markdown_versions.create!(value: description, latest: true)
    # rubocop:disable Rails/SkipsModelValidations
    question.touch(:last_activity_at)
    # rubocop:enable Rails/SkipsModelValidations
    answer.id
  end

  def authorized?
    # Can't answer at PupilFirst.
    raise UnauthorizedMutationException if current_school.blank?

    # Only a student or coach can answer.
    raise UnauthorizedMutationException if current_founder.blank? && current_coach.blank?

    # Can only answer questions in the same school.
    raise UnauthorizedMutationException if question&.school != current_school

    true
  end

  private

  def question
    @question ||= Question.find_by(id: question_id)
  end
end
