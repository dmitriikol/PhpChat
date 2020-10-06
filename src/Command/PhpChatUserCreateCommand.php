<?php

namespace App\Command;

use App\Entity\User;
use App\Repository\UserRepository;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;
use Symfony\Component\Security\Core\Encoder\UserPasswordEncoderInterface;

class PhpChatUserCreateCommand extends Command
{
    protected static $defaultName = 'php-chat:user:create';

    private UserRepository $userRepository;

    private UserPasswordEncoderInterface $passwordEncoder;

    public function __construct(UserRepository $userRepository, UserPasswordEncoderInterface $userPasswordEncoder)
    {
        parent::__construct(null);
        $this->userRepository = $userRepository;
        $this->passwordEncoder = $userPasswordEncoder;
    }

    protected function configure()
    {
        $this
            ->setDescription('Creates a new user.')
            ->addOption('username', 'u', InputOption::VALUE_REQUIRED, 'username')
            ->addOption('email', 'm', InputOption::VALUE_REQUIRED, 'email')
            ->addOption('password', 'p', InputOption::VALUE_REQUIRED, 'User password')
            ->addOption('firstName', 'f', InputOption::VALUE_REQUIRED, 'User first name')
            ->addOption('lastName', 'l', InputOption::VALUE_REQUIRED, 'User last name')
            ->addOption('role', 'r', InputOption::VALUE_REQUIRED, 'User Role: "manager" or "admin"', 'manager');;
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $io = new SymfonyStyle($input, $output);
        $username = $input->getOption('username');
        $email = $input->getOption('email');
        $password = $input->getOption('password');
        $firstName = $input->getOption('firstName');
        $lastName = $input->getOption('lastName');
        $role = $input->getOption('role');

        $user = User::buildNew($username, $email, $firstName, $lastName, [$role]);

        $user->setPassword(
            $this->passwordEncoder->encodePassword(
                $user,
                $password
            )
        );

        $this->userRepository->update($user);

        $io->success(
            sprintf(
                'User "%s" with role "%s" created successfully.',
                $user->getUsername(),
                implode('", "', $user->getRoles())
            )
        );

        return 0;
    }
}
