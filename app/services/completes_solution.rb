class CompletesSolution
  def self.complete!(*args)
    new(*args).complete!
  end

  attr_reader :solution
  def initialize(solution)
    @solution = solution
  end

  def complete!
    if solution.approved?
      completed_approved
    else
      # Beta ?
      completed_approved
      #completed_unapproved
    end

    unlock_next_core_exercise if solution.exercise.core?
  end

  private

  def completed_approved
    update_solution_record

    # Unlock side quests
    existing_exercise_ids = user.solutions.pluck(:exercise_id)
    solution.exercise.unlocks.each do |exercise|
      next if existing_exercise_ids.include?(exercise.id)
      CreatesSolution.create!(user, exercise)
    end
  end

  def completed_unapproved
    update_solution_record
  end

  def update_solution_record
    solution.update!( completed_at: DateTime.now )
  end

  def unlock_next_core_exercise
    next_exercise = solution.exercise.track.exercises.where(core: true).
                      reorder('position ASC').
                      where("position > ?", solution.exercise.position).
                      first
    if next_exercise
      # Don't double-create
      unless user.solutions.where(exercise_id: next_exercise.id).exists?
        CreatesSolution.create!(user, next_exercise)
      end
    else
      # TODO - complete track
      raise "Not Implemented"
    end
  end

  def user
    solution.user
  end
end

