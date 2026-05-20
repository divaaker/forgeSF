trigger ValidateDeleteAccountTeam on AccountTeamMember (before delete) {
    system.debug(Trigger.new);
    for(AccountTeamMember ACT : Trigger.old){
        ACT.addError('You can not delete account team member');
    }
}