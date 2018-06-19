class Teams::InvitationsController < TeamsController
  skip_before_action :find_team, only: [:destroy]

  def create
    emails = params[:emails].to_s.split("\n").map(&:strip).compact
    emails.each do |email|
      CreateTeamInvitation.(@team, current_user, email)
    end

    redirect_to [:teams, @team, :memberships]
  end

  def destroy
    invitation = TeamInvitation.
      where(team_id: current_user.managed_teams.select(:id)).
      find(params[:id])

    invitation.destroy!

    redirect_to teams_team_memberships_path(invitation.team)
  end
end
